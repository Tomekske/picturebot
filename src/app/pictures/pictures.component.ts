import { ChangeDetectorRef, Component, OnInit, ViewChild } from '@angular/core';
import { MatTabGroup } from '@angular/material/tabs';
import { ElectronService } from 'app/core/services';
import { DataService } from 'app/services/data.service';
import { Subscription } from 'rxjs';
import { IAlbum, IFlow, IPreview } from '../../../shared/database/interfaces';
import { Helper } from '../../../shared/helper/helper';
import { Logger } from '../../../shared/logger/logger';
import { MatDialog } from '@angular/material/dialog';
import { DialogPictureInfoComponent } from 'app/dialogs/dialog-picture-info/dialog-picture-info.component';
import { IpcFrontend } from '../../../shared/ipc/frontend';

@Component({
  selector: 'app-pictures',
  templateUrl: './pictures.component.html',
  styleUrls: ['./pictures.component.css']
})
export class PicturesComponent implements OnInit {
  previewList: IPreview[] = [];
  base64List: string[] = [];
  _albums = [];
  selectedFlow: string;
  flows: string[] = [];
  tabFlows: IFlow;
  selectedAlbum: IAlbum;
  selectedCollection: string;
  @ViewChild('tab') tabGroup: MatTabGroup;
  subscription: Subscription; 
  albums: IAlbum[] = [];
  isVisible: boolean = false;
  subsAlbumVisible: Subscription; 
  subsAlbums: Subscription; 
  
  constructor(private _electron: ElectronService, private _data: DataService, private cdRef:ChangeDetectorRef, private _dialog: MatDialog) { }
  
  /**
   * On init lifecycle hook
   */
  ngOnInit(): void {
    // Monitor for collection changes
    this._data.ctxSelectedCollection.subscribe(collection => {
      this.selectedCollection = collection;
      
      // Get the albums within a certain collection
      this.albums = IpcFrontend.getAlbums(collection);
      // Make the album selector visible
      this.isVisible = this._data.isAlbumSelectorVisible;

      // Select the first album as the default album
      if (typeof this.albums[0] !== 'undefined') {
        this.selectedAlbumEvent(this.albums[0]);
      }
    });
  }

  /**
   * Select a flow using the tab component
   * @param event Tab events
   */
  selectedFlowEvent(event) {
    this.selectedFlow = event.tab.textLabel;
    this._data.selectedFlow = event.tab.textLabel;
    this.displayPictures();
  }

  /**
   * Display picture from a selected flow
   */
  displayPictures() {
    // Clear array when a flow is selected
    this.previewList = [];

    // Display pictures from a selected flow
    if(this.selectedFlow == this.tabFlows.preview) {
      IpcFrontend.getPreviewFlowPictures(this.selectedAlbum.album).forEach((picture: IPreview) => {
        this.base64List.push(Helper.encodeBase64(picture.preview));
      });
    } else if(this.selectedFlow == this.tabFlows.edited) {
      // Edited flow is selected
    } else if(this.selectedFlow == this.tabFlows.socialMedia) {
      // Social media flow is selected
    } else {
      Logger.Log().error(`Selected flow: invalid flow is selected`);
    }
  }

  /**
   * Select an album from the list
   */
  selectedAlbumEvent(album: IAlbum) {
    this.flows = [];
    this.selectedAlbum = album;
    this._data.selectedAlbum = album;
    this.tabFlows = IpcFrontend.getTabFlows(album.collection);

    this.displayFlows(this.tabFlows);
    this.displayPictures();
  }

  /**
   * Display the tab flow in the tab component 
   */
  displayFlows(flows: IFlow) {
    // Display the the flows in the tab selector in a specified order
    this.flows.push(flows.preview);
    this.flows.push(flows.edited);
    this.flows.push(flows.socialMedia);
    this.selectedFlow = flows.preview;
    this._data.selectedFlow = flows.preview;

    // Make sure the first flow is selected by default
    this.cdRef.detectChanges();
    this.tabGroup.selectedIndex = this.flows.indexOf(flows.preview);
  }

  /**
   * Display a picture's metadata
   * @param index Index of the picture within the array
   */
  openPictureInformation(index: number) {
    this.previewList = [];
    this.previewList = IpcFrontend.getPreviewFlowPictures(this.selectedAlbum.album);

    this._dialog.open(DialogPictureInfoComponent, { 
      data: 
        { album: this.previewList[index] }
    });
  }
}
