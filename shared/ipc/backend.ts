import { app, BrowserWindow, screen, ipcMain, remote } from 'electron';
import * as path from 'path';
import * as url from 'url';
import * as fs from 'fs';
import * as cp from 'child_process';

import { DbCollection } from '../database/dbCollection';
import { DbLibrary } from '../database/dbLibrary';
import { DbSettings } from '../database/dbSettings';
import { DbAlbum } from '../database/dbAlbum';
import { IAlbum, IBackup, IBase, ICollection, IFlow, ILibrary, IPreview, IEdited, ISocialMedia, ILegacy } from '../database/interfaces';
import { Helper } from '../helper/helper';
import { Logger } from '../logger/logger';
import { DbBaseFlow } from '../database/dbBaseFlow';
import { DbBackupFlow } from '../database/dbBackupFlow';
import { DbPreviewFlow } from '../database/dbPreviewFlow';
import { DbFavoriteFlow } from '../database/dbFavoriteFlow';
import { DbEditedFlow } from '../database/dbEditedFlow';
import { DbSocialMediaFlow } from '../database/dbSocialMediaFlow';
import { Api } from '../database/api';
var watch = require('node-watch');

/**
 * Static class contains methods to communicate with the backend 
 */
export class  IpcBackend {
    /**
     * Get settings from the database
     */
    static getSettings() {
        ipcMain.on('get-settings', (event) => {
            Logger.Log().debug('ipcMain: get-settings');
        
            const db = new DbSettings();
            let result = db.queryAll();

            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Save settings to the database
     */
    static saveSettings() {
        ipcMain.on('save-settings', (event, args) => {
            Logger.Log().debug('ipcMain: save-settings');
        
            // Create database
            const db = new DbSettings();
            
            // If table exists update database
            db.isEmpty() ? db.insertRow(args) : db.updateRow(args);
            db.dbClose();
        });
    }

    /**
     * Check wether the settings row is empty
     */
    static checkSettingsEmpty() {
        ipcMain.on('check-settings-empty', (event) => {
            Logger.Log().debug('ipcMain: check-settings-empty');
        
            const db = new DbSettings();
            let result = db.isEmpty();
        
            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Get all libraries from the database
     */
    static getLibraries() {
        ipcMain.on('get-libraries', (event, args: ILibrary) => {
            Logger.Log().debug('ipcMain: get-libraries');
        
            // Create database
            const db = new DbLibrary();
            let result = db.queryLibraries();
            
            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Save library to the database
     */
    static saveLibrary() {
        ipcMain.on('save-library', (event, args: ILibrary) => {
            Logger.Log().debug('ipcMain: save-library');
        
            // Create database
            const db = new DbLibrary();
        
            // Insert data and close database
            db.insertRow(args);
            db.dbClose();
        
            Helper.createDirectory(args.library);
        });
    }

    /**
     * Get all collections from the database
     */
    static getCollections() {
        ipcMain.on('get-collections', (event, args: ILibrary) => {
            Logger.Log().debug('ipcMain: get-collections');
        
            // Create database
            const db = new DbCollection();
            let result = db.queryCollections();
            
            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Method to query all values from the collection table of a specified collection
     */
    static getAllCollectionWhereCollection() {
        ipcMain.on('get-all-collections-where-collection', (event, collection: string) => {
            Logger.Log().debug('ipcMain: get-all-collections-where-collection');
        
            // Create database
            const db = new DbCollection();
            let result = db.queryAllWhereCollection(collection);
            
            db.dbClose();
            event.returnValue = result;
        });    
    }

    /**
     * Save collection to the database
     */
    static saveCollection() {
        ipcMain.on('save-collection', (event, args: ICollection) => {
            Logger.Log().debug('ipcMain: save-collection');
        
            // Create database
            const db = new DbCollection();
        
            db.insertRow(args);
            db.dbClose();
        
            Helper.createDirectory(args.collection);
        });    
    }

    /**
     * Hashed pictures which are saved to the database
     */
    static savePictures() {
        ipcMain.on('save-pictures', (event, args: IBase[], album: IAlbum) => {
            Logger.Log().debug('ipcMain: save-pictures');
        
            const dbSettings = new DbSettings();
        
            // Create database
            const albumDb = new DbAlbum();
        
            albumDb.insertRow(album);
            albumDb.dbClose();
        
            //Create album
            Helper.createDirectory(album.album);
        
            if (Helper.isDirectory(album.album)) {
              const collectionDb = new DbCollection();
              let flows: IFlow = collectionDb.queryAllFlows(album.collection);
        
              // Creating flow directories
              Object.values(flows).forEach(flow => {
                // The selection flow is a virtual directory, so it doesn't need to be created
                if(flow != flows.favorites) {
                  Helper.createDirectory(path.join(album.album, flow));
                }
              });
        
              collectionDb.dbClose();
        
              // pictures
              const picDb = new DbBaseFlow();
              const backupDb = new DbBackupFlow();
              const dbPreview = new DbPreviewFlow();
           
              // pipeline
              args.forEach((picture: IBase) => {
                const destBase: string = path.join(album.collection,`${album.name} ${album.date}`, flows.base, picture.hashed);
                const destBackup: string = path.join(album.collection,`${album.name} ${album.date}`, flows.backup, picture.hashed);
                const destPreview: string = path.join(album.collection,`${album.name} ${album.date}`, flows.preview, `${picture.hashed.split('.')[0]}.jpg`);
                
                let dataBaseFlow: IBase = { collection: album.collection, name: picture.name, album: album.album, favorited: 0, backup: destBackup,preview: destPreview, base: destBase, date: picture.date, time: picture.time};
                let dataBackupFlow: IBackup = { collection: album.collection, name: picture.name, album: album.album, backup: destBackup, date: picture.date, time: picture.time};
                let dataPreviewFlow: IPreview = { collection: album.collection, name: picture.name, album: album.album, base: destBase, preview: destPreview, date: picture.date, time: picture.time}; 
        
                // copy base
                Helper.copyFile(picture.source, path.join(path.dirname(destBase), picture.hashed));
        
                // Insert data into database
                picDb.insertRow(dataBaseFlow);
        
                // copy backup
                Helper.copyFile(picture.source, path.join(path.dirname(destBackup), picture.hashed));
        
                // Insert data into database
                backupDb.insertRow(dataBackupFlow);
                
                // convert preview
                const convert = `magick convert \"${picture.source}\" -quality ${dbSettings.queryConversion()} -verbose \"${destPreview}\"`  
                cp.execSync(convert);
        
                dbPreview.insertRow(dataPreviewFlow);
        
                Logger.Log().debug(convert);
              });
        
              picDb.dbClose();
              backupDb.dbClose();
              dbPreview.dbClose();
              dbSettings.dbClose();
            }
        
            event.returnValue = "";
        });
    }

    /**
     * Update the name object of the preview flow
     */
    static updatePreviewFlowName() {
        ipcMain.on('update-name-previewFlow', (event, update) => {
            Logger.Log().debug('ipcMain: update-name-previewFlow');
        
            const db = new DbPreviewFlow();
        
            db.updateName(update);
            db.updatePreview(update);
            db.updateBase(update);
            db.dbClose();
            
            event.returnValue = "";
        });
    }

    /**
     * Get pictures from a specified album of the preview flow
     */
    static getPreviewFlowPictures() {
        ipcMain.on('get-previewFLow-pictures', (event, args) => {
            Logger.Log().debug('get-previewFlow-pictures');
        
            // Create database
            const db = new DbPreviewFlow();
            let result = db.queryAllWhereAlbum(args);

            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Get pictures from a specified album of the favorites flow
     */
    static getFavoritesFlowPictures() {
        ipcMain.on('get-favoritesFlow-pictures', (event, args) => {
            Logger.Log().debug('get-previewFlow-pictures');
        
            // Create database
            const db = new DbFavoriteFlow();
            let result = db.queryAllWhereAlbum(args);

            db.dbClose();
            event.returnValue = result;
        });
    }
    
    /**
     * Update the name object of the base flow
     */
    static updateBaseFlowName() {
        ipcMain.on('update-name-baseFlow', (event, update) => {
            Logger.Log().debug('ipcMain: update-name-baseFlow');
        
            const dbBase = new DbBaseFlow();
            dbBase.updateName(update);
            dbBase.updateBase(update);
            dbBase.updatePreview(update);
            dbBase.dbClose();

            const dbBackup = new DbBackupFlow();
            dbBackup.updateBase(update);
            dbBackup.dbClose();
            
            event.returnValue = "";
        });
    }

    /**
     * Get pictures from a specified album of the base flow
     */
    static getBaseFlowPictures() {
        ipcMain.on('get-baseFLow-pictures', (event, album: string) => {
            Logger.Log().debug('ipcMain: get-baseFLow-pictures');
        
            const db = new DbBaseFlow();
            let result = db.queryBaseFlow(album);

            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Get the preview and base flow from a certain collection
     */
    static getStartingFlows() {
        ipcMain.on('get-started-flow', (event, collection: string) => {
            Logger.Log().debug('ipcMain: get-started-flow');
        
            const db = new DbCollection();
            let result = db.queryRenameStartedFlows(collection);

            db.dbClose();
            event.returnValue = result;
        });    
    }

    /**
     * Update the isOrganized value of a certain album
     */
    static updateAlbumIsOrganized() {
        ipcMain.on("update-album-started", (event, album: IAlbum, isOrganized: boolean) => {
            Logger.Log().debug('ipcMain: update-album-started');
        
            const db = new DbAlbum();
        
            db.updateStartedRecord(isOrganized ? 1 : 0, album.album);
        
            event.returnValue = "";
        });
    }

    /**
     * Get albums from a specified album
     */
    static getAlbums() {
        ipcMain.on('get-albums', (event, args) => {
            Logger.Log().debug('ipcMain: get-albums');
        
            // Create database
            const db = new DbAlbum();
            let result = db.queryAlbums(args);
        
            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Save an album to the database
     */
    static updateAlbum() {
        ipcMain.on('update-album', (event, currentAlbum: string, updatedAlbum: IAlbum) => {
            Logger.Log().debug('ipcMain: update-album');
        
            // Create database
            const db = new DbAlbum();
            db.deleteAlbum(currentAlbum);   
            db.insertRow(updatedAlbum);
            db.dbClose();

            // Edit the album name in associated tables
            const backupDb = new DbBackupFlow();
            backupDb.updateAlbum(currentAlbum, updatedAlbum.album);
            backupDb.dbClose();

            const baseDb = new DbBaseFlow();
            baseDb.updateAlbum(currentAlbum, updatedAlbum.album);
            baseDb.dbClose();

            const previewDb = new DbPreviewFlow();
            previewDb.updateAlbum(currentAlbum, updatedAlbum.album);
            previewDb.dbClose();

            event.returnValue = "";
        });    
    }

    /**
     * Get the flows which are displayed in the tab component
     */
    static getTabFlows() {
        ipcMain.on('get-tab-flows', (event, collection: string) => {
            Logger.Log().debug('ipcMain: get-tab-flows');
        
            const db = new DbCollection();
            let result = db.queryFlows(collection);
        
            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Delete a picture relation from the previewFlow table
     */
    static previewFlowDeletePicture() {
        ipcMain.on('previewFlow-delete-picture', (event, path: string) => {
            Logger.Log().debug('ipcMain: previewFlow-delete-picture');
        
            const db = new DbPreviewFlow();
            db.deletePicture(path);
        
            db.dbClose();

            Helper.deletePicture(path);
            event.returnValue = "";
        });    
    }

    /**
     * Delete a picture relation from the baseFlow table
     */
    static baseFlowDeletePicture() {
        ipcMain.on('baseFlow-delete-picture', (event, path: string) => {

            Logger.Log().debug('ipcMain: previewFlow-delete-picture');
        
            const db = new DbBaseFlow();
            db.deletePicture(path);
        
            db.dbClose();
            Helper.deletePicture(path);
            event.returnValue = "";
        });    
    }

    /**
     * Delete a picture relation from the previewFlow table
     */
    static favoriteFlowDeletePicture() {
        ipcMain.on('favoriteFlow-delete-picture', (event, path: string) => {
            Logger.Log().debug('ipcMain: favoriteFlow-delete-picture');
        
            const db = new DbFavoriteFlow();
            db.deletePicture(path);
            db.dbClose();

            event.returnValue = "";
        });    
    }

    /**
     * Delete an album reference from the database
     * All relations within the baseFlow, previewFlow and backupFlow will get deleted
     */
    static deleteAlbum() {
        ipcMain.on('delete-album', (event, album: IAlbum) => {
            Logger.Log().debug('ipcMain: delete-album');
        
            const dbAlbum = new DbAlbum();
            dbAlbum.deleteAlbum(album.album);   
            dbAlbum.dbClose();

            const dbPreviewFlow = new DbPreviewFlow();
            dbPreviewFlow.deletePicturesWhereAlbum(album.album);   
            dbPreviewFlow.dbClose();

            const dbBaseFlow = new DbBaseFlow();
            dbBaseFlow.deletePicturesWhereAlbum(album.album);   
            dbBaseFlow.dbClose();

            const dbBackupFlow = new DbBackupFlow();
            dbBackupFlow.deletePicturesWhereAlbum(album.album);   
            dbBackupFlow.dbClose();

            const dbFavorite = new DbFavoriteFlow();
            dbFavorite.deletePicturesWhereAlbum(album.album);
            dbFavorite.dbClose();

            event.returnValue = "";
        });    
    }

    /**
     * Get the favorite picture from the base flow from a preview picture
     */
    static getIsFavoriteBaseFlowWherePreview() {
        //ipcRenderer.sendSync("get-isFavorite-baseFlow-where-preview", preview);
        ipcMain.on('get-isFavorite-baseFlow-where-preview', (event, preview: string) => { 
            const db = new DbBaseFlow();
            let isFavorite = db.getIsFavoriteWherePreview(preview);
            db.dbClose();

            event.returnValue = isFavorite;
        });
    }

    /**
     * Update the favorited boolean of a specified picture
     */
    static updateFavorited() {
        ipcMain.on('update-favorited', (event, preview: string, isFavorited: boolean) => { 
            const db = new DbBaseFlow();
            db.updateFavorited(preview, ((isFavorited == true) ? 1 : 0));
            db.dbClose();

            event.returnValue = "";
        });
    }

    /**
     * Save a favorited picture to the favorite flow
     */
    static saveFavorite() {
        ipcMain.on('save-favorite', (event, favorite) => {
            Logger.Log().debug('ipcMain: save-favorite');

            const db = new DbFavoriteFlow();
            db.insertRow(favorite);
            db.dbClose();

            event.returnValue = "";
        });
    }

    /**
     * Delete a favorited picture from the favorite flow
     */
    static deleteFavoriteWhereBase() {
        ipcMain.on('delete-favorite-where-base', (event, base: string) => {
            Logger.Log().debug('ipcMain: delete-favorite-where-base');

            const db = new DbFavoriteFlow();
            db.deletePictureWhereBase(base);
            db.dbClose();

            event.returnValue = "";
        });
    }

    /**
     * Update the selected album in the main process
     * @param album Selected album
     */
    static selectedAlbum() {
        ipcMain.on('selected-album', (event, album: IAlbum) => {
            Logger.Log().debug('ipcMain: selected-album');
            console.log(album);
            const db = new DbCollection();
            let flows: IFlow = db.queryFlows(album.collection);
            db.dbClose();

            watch(path.join(album.album, flows.edited), (event, name) => {
                // Create database
                const dbFlow = new DbPreviewFlow();
                let picture: IPreview = dbFlow.queryBaseWhereName(Helper.BasenameWithoutExtension(name));
                db.dbClose();

                const dbEdited = new DbEditedFlow();
                const pathEdited = path.join(album.album, flows.edited, path.basename(name));

                if (event == 'update') {
                    try {
                        let data: IEdited = { collection: album.collection, album: album.album, preview: picture.preview, base: picture.base, edited: pathEdited };
                        dbEdited.insertRow(data);
    
                    } catch (error) {
                        console.log("OOOOPS");
                    }
                }
            
                if (event == 'remove') {
                    console.log(`REMOVED EDITED: ${name}`);
                    dbEdited.deleteWhereEdited(pathEdited);

                }

                dbEdited.dbClose();
            });

            // Social media flow
            watch(path.join(album.album, flows.socialMedia), (event, name) => {
                // Create database
                const dbFlow = new DbPreviewFlow();
                let picture: IPreview = dbFlow.queryBaseWhereName(Helper.BasenameWithoutExtension(name));
                db.dbClose();

                const dbSocialMedia = new DbSocialMediaFlow();
                const pathSocialMedia = path.join(album.album, flows.socialMedia, path.basename(name));

                if (event == 'update') {
                    try {
                        let data: ISocialMedia = { collection: album.collection, album: album.album, preview: picture.preview, base: picture.base, socialMedia: pathSocialMedia };
                        dbSocialMedia.insertRow(data);
    
                    } catch (error) {
                        console.log("OOOOPS");
                    }
                }
            
                if (event == 'remove') {
                    dbSocialMedia.deleteWhereSocialMedia(pathSocialMedia);
                }

                dbSocialMedia.dbClose();
            });

            //selectedAlbum = album
            event.returnValue = "";
        }); 
    }

    /**
     * Get pictures from a specified album of the edited flow
     */
    static getEditedFlowPictures() {
        ipcMain.on('get-editedFlow-pictures', (event, args) => {
            Logger.Log().debug('get-editedFlow-pictures');
        
            // Create database
            const db = new DbEditedFlow();
            let result = db.queryAllWhereAlbum(args);

            db.dbClose();
            event.returnValue = result;
        });
    }

    /**
     * Get pictures from a specified album of the social media flow
     */
    static getSocialMediaFlowPictures() {
        ipcMain.on('get-socialMediaFlow-pictures', (event, args) => {
            Logger.Log().debug('get-socialMediaFlow-pictures');
        
            // Create database
            const db = new DbSocialMediaFlow();
            let result = db.queryAllWhereAlbum(args);

            db.dbClose();
            event.returnValue = result;
        });
    }

    static importLegacyAlbum() {
        ipcMain.on('import-legacy-album', (event, form: ILegacy) => {
            Logger.Log().debug('import-legacy-album');
            
            interface ILocation {
                source: string;
                destination: string;
            }

            interface ILegacyAlbum {
                base?: ILocation;
                backup?: ILocation;
                preview?: ILocation;
                favorited?: {
                    isFavorited: number;
                    source: string;
                }; 
                edited?: ILocation;
                socialMedia?: ILocation;
                time?: string;
            }

            let album: IAlbum = {
                album: path.join(form.collection, path.basename(form.legacy)),
                collection: form.collection,
                name: /(\w+( +\w+)*) \d+-\d+-\d+/.exec(form.legacy)[1].toString(), 
                date: path.basename(form.legacy.split(" ").pop()),
                started: 1,
                raw: 1
            }

            // Create the album and get the flows of that album
            Api.createAlbum(album);
            let flows: IFlow = Api.getFlows(album);

            // Map all pictures within every flow
            if (fs.existsSync(form.legacy)) {
                fs.readdirSync(path.join(form.legacy, form.backup)).forEach(pictureBackup => {
                    let source = path.join(form.legacy, flows.backup, pictureBackup);
                    let destination = path.join(album.album, flows.backup, pictureBackup);
                    
                    let backupStat = fs.statSync(source); 

                    Api.insertBackupIntoDatabase({
                        collection: form.collection,
                        name: album.name,
                        album: album.album,
                        backup: destination,
                        date: album.date,
                        time: Helper.formatTime(backupStat.mtime.toISOString())
                    });

                    Helper.copyFile(source, destination);
                });

                fs.readdirSync(path.join(form.legacy, form.base)).forEach(pictureBase => {
                    let obj: ILegacyAlbum = {};
                    let source: string = path.join(form.legacy, form.base, pictureBase);
                    let destination = path.join(album.album, flows.base, pictureBase);

                    let baseStat = fs.statSync(source); 
                    obj.time = Helper.formatTime(baseStat.mtime.toISOString());

                    obj.base = { source: source, destination: destination};
                    obj.favorited = { isFavorited: 0, source: ""};
                    
                    // Backup flow
                    fs.readdirSync(path.join(form.legacy, form.backup)).forEach(pictureBackup => {
                        let backupStat = fs.statSync(path.join(form.legacy, form.backup, pictureBackup));

                        if(baseStat.size == backupStat.size && baseStat.mtimeMs == backupStat.mtimeMs) {
                            obj.backup = { source: path.join(form.legacy, form.backup, pictureBackup), destination: path.join(form.collection, flows.backup, pictureBackup)};
                        }
                    });

                    // Preview flow
                    fs.readdirSync(path.join(form.legacy, form.preview)).forEach(picturePreview => {
                        if(Helper.BasenameWithoutExtension(pictureBase) == Helper.BasenameWithoutExtension(picturePreview)) {
                            obj.preview = { source: path.join(form.legacy, form.preview, picturePreview), destination: path.join(album.album, flows.preview, picturePreview)};
                        }
                    });

                    // Edited flow
                    fs.readdirSync(path.join(form.legacy, form.edited)).forEach(pictureEdited => {
                        if(Helper.BasenameWithoutExtension(pictureBase) == Helper.BasenameWithoutExtension(pictureEdited)) {
                            obj.edited = { source: path.join(form.legacy, form.edited, pictureEdited), destination: path.join(album.album, flows.edited, pictureEdited)};

                            Api.insertEditedIntoDatabase({
                                collection: form.collection,
                                album: album.album,
                                preview: obj.preview.destination, 
                                base: obj.base.destination,
                                edited: obj.edited.destination
                            });

                            Helper.copyFile(obj.edited.source, obj.edited.destination);
                        }
                    });

                    // Social-Media flow
                    fs.readdirSync(path.join(form.legacy, form.socialMedia)).forEach(pictureSocialMedia => {
                        if(Helper.BasenameWithoutExtension(pictureBase) == Helper.BasenameWithoutExtension(pictureSocialMedia)) {
                            obj.socialMedia = { source: path.join(form.legacy, form.socialMedia, pictureSocialMedia), destination: path.join(album.album, flows.socialMedia, pictureSocialMedia)};

                            Api.insertSocialMediaIntoDatabase({
                                collection: form.collection,
                                album: album.album,
                                preview: obj.preview.destination, 
                                base: obj.base.destination,
                                socialMedia: obj.socialMedia.destination
                            });

                            Helper.copyFile(obj.socialMedia.source, obj.socialMedia.destination);
                        }
                    });

                    // Favorites flow
                    fs.readdirSync(path.join(form.legacy, form.favorites)).forEach(pictureFavorites => {
                        
                        if(Helper.BasenameWithoutExtension(pictureBase) == Helper.BasenameWithoutExtension(pictureFavorites)) {
                            obj.favorited = { isFavorited: 1, source: path.join(form.legacy, form.socialMedia, pictureFavorites)};

                            Api.insertFavoriteIntoDatabase({
                                collection: form.collection,
                                album: album.album,
                                preview: obj.preview.destination, 
                                base: obj.base.destination,
                            });
                        }
                    });

                    Api.insertBaseIntoDatabase({
                        collection: form.collection,
                        name: album.name,
                        album: album.album,
                        favorited: obj.favorited.isFavorited,
                        backup: obj.backup.destination,
                        preview: obj.preview.destination, 
                        base: obj.base.destination,
                        date: album.date,
                        time: obj.time
                    });

                    Api.insertPreviewIntoDatabase({
                        collection: form.collection,
                        name: album.name,
                        album: album.album,
                        base: obj.base.destination,
                        preview: obj.preview.destination, 
                        date: album.date,
                        time: obj.time
                    });

                    // copy to base flow
                    Helper.copyFile(obj.base.source, obj.base.destination);
                    // copy to preview flow
                    Helper.copyFile(obj.preview.source, obj.preview.destination);

                });
            }   
            event.returnValue = "";
        });
    }   
}
