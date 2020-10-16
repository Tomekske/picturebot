import 'reflect-metadata';
import '../polyfills';

import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule, HttpClient } from '@angular/common/http';
import { CoreModule } from './core/core.module';
import { SharedModule } from './shared/shared.module';
import { NgxDropzoneModule } from 'ngx-dropzone';
import { ListViewModule } from '@syncfusion/ej2-angular-lists';
import { RouterModule, Routes } from '@angular/router';
// NG Translate
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

import { AppComponent } from './app.component';
import { MenuComponent } from './menu/menu.component';
import { FooterComponent } from './footer/footer.component';
import { SettingsComponent } from './settings/settings.component';
import { WindowComponent } from './window/window.component';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { ShootSelectorComponent } from './shoot-selector/shoot-selector.component';
import { FlowSelectorComponent } from './flow-selector/flow-selector.component';
import { LibraryComponent } from './library/library.component';
import { AlbumComponent } from './album/album.component';
import { CollectionComponent } from './collection/collection.component';

import { DataService } from './data.service';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MaterialModule } from './material/material.module';
import { FlexLayoutModule } from '@angular/flex-layout'
// AoT requires an exported function for factories
export function HttpLoaderFactory(http: HttpClient): TranslateHttpLoader {
  return new TranslateHttpLoader(http, './assets/i18n/', '.json');
}

@NgModule({
  declarations: [AppComponent, MenuComponent, FooterComponent, SettingsComponent, WindowComponent, ToolbarComponent, ShootSelectorComponent, FlowSelectorComponent, LibraryComponent, AlbumComponent, CollectionComponent],
  imports: [
    BrowserModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    CoreModule,
    SharedModule,
    NgxDropzoneModule,
    ListViewModule,
    NgbModule,
    FlexLayoutModule,
    TranslateModule.forRoot({
      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient]
      }
    }),
    BrowserAnimationsModule,
    MaterialModule,
    RouterModule.forRoot([
      {path: 'main', component: WindowComponent},
      {path: 'settings', component: SettingsComponent},
      {path: 'addAlbum', component: AlbumComponent},
      {path: 'addCollection', component: CollectionComponent},
      {path: 'addLibrary', component: LibraryComponent}
    ])
  ],
  providers: [DataService],
  bootstrap: [AppComponent]
})
export class AppModule {}
