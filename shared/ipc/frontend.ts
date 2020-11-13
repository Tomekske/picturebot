import { ipcRenderer } from 'electron';
import { IAlbum, IBase } from '../database/interfaces';

/**
 * Static class contains methods to communicate with the backend 
 */
export class  IpcFrontend {
    /**
     * Get settings from the database
     */
    static getSettings() {
        return ipcRenderer.sendSync("get-settings");
    }

    /**
     * Save settings to the database
     * @param data Form data which is stored within the database
     */
    static saveSettings(data) {
        ipcRenderer.send("save-settings", data);
    }

    /**
     * Check wether the settings row is empty
     */
    static checkSettingsEmpty() {
        return ipcRenderer.sendSync("check-settings-empty");
    }

    /**
     * Get all libraries from the database
     */
    static getLibraries() {
        return ipcRenderer.sendSync("get-libraries");
    }

    /**
     * Save library to the database
     * @param data Form data which is stored within the database
     */
    static saveLibrary(data) {
        ipcRenderer.send("save-library", data);
    }

    /**
     * Get all collections from the database
     */
    static getCollections() {
        return ipcRenderer.sendSync("get-collections");
    }

    /**
     * Save collection to the database
     * @param data Form data which is stored within the database
     */
    static saveCollection(data) {
        ipcRenderer.send("save-collection", data);
    }

    /**
     * Hashed pictures which are saved to the database
     * @param pictures Pictures that are saved to the database
     * @param album The album where the pictures should be stored in
     */
    static savePictures(pictures: IBase[], album: IAlbum) {
        ipcRenderer.sendSync("save-pictures", pictures, album);
    }

    /**
     * Update the name object of the preview flow
     * @param data The updated value
     */
    static updatePreviewFlowName(data) {
        ipcRenderer.sendSync("update-name-previewFlow", data);
    }

    /**
     * Get pictures from a specified album of the preview flow
     * @param album Selected album
     */
    static getPreviewFlowPictures(album: string) {
        return ipcRenderer.sendSync("get-previewFLow-pictures", album);
    }
    
    /**
     * Update the name object of the base flow
     * @param data The updated value
     */
    static updateBaseFlowName(data) {
        ipcRenderer.sendSync("update-name-baseFlow", data);
    }

    /**
     * Get pictures from a specified album of the base flow
     * @param album Selected album
     */
    static getBaseFlowPictures(album: string) {
        return ipcRenderer.sendSync("get-baseFLow-pictures", album);
    }

    /**
     * Get the preview and base flow from a certain collection
     * @param collection Selected collection
     */
    static getStartingFlows(collection: string) {
        return ipcRenderer.sendSync("get-started-flow", collection);
    }

    /**
     * Update the isOrganized value of a certain album
     * @param album Selected album
     * @param isOrganized Updated value
     */
    static updateAlbumIsOrganized(album: IAlbum, isOrganized: boolean) {
        ipcRenderer.sendSync("update-album-started", album, isOrganized);
    }

    /**
     * Get albums from a specified album
     * @param collection Selected collection
     */
    static getAlbums(collection: string) {
        return ipcRenderer.sendSync("get-albums", collection);
    }

    /**
     * Get the flows which are displayed in the tab component
     * @param collection Selected collection
     */
    static getTabFlows(collection: string) {
        return ipcRenderer.sendSync("get-tab-flows", collection);
    }

    /**
     * Delete a picture relation from the previewFlow table
     * @param path Path to the picture
     */
    static previewFlowDeletePicture(path: string) {
        ipcRenderer.sendSync("previewFlow-delete-picture", path);
    }

    /**
     * Delete a picture relation from the baseFlow table
     * @param path Path to the picture
     */
    static baseFlowDeletePicture(path: string) {
        ipcRenderer.sendSync("baseFlow-delete-picture", path);
    }

    /**
     * Delete an album reference from the database
     * @param album Album that get deleted
     */
    static deleteAlbum(album: IAlbum) {
        ipcRenderer.sendSync("delete-album", album);
    }
}
