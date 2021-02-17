//
//  DropZoneView.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

@objc protocol DropZoneDelegate: NSDraggingDestination {
    
    /// Redirect of the draggingEntered function (optional)
    @objc optional func draggingEntered(info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingUpdated function (optional)
    @objc optional func draggingUpdated(info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingExited function (optional)
    @objc optional func draggingExited(info: NSDraggingInfo)
    
    /// Redirect of the prepareForDragOperation (optional)
    @objc optional func prepareForDragOperation(info: NSDraggingInfo) -> Bool
    
    /// Redirect of the performDragOperations (required)
    func performDragOperation(info: NSDraggingInfo) -> Bool
    
}

class DropZoneView: NSView {

//MARK: - Instance variables
    
    @IBOutlet var dropDelegate: DropZoneDelegate?
    
    /// The array holding the file extensions that are accepted (e.g. ["mp3", "aac"])
    var acceptedFiles: [String] = []
    
    /// The dragOperation that will de returned if an optoinal DropZoneDelegate function has not been implemented
    var defaultDragOperation = NSDragOperation.copy
    
    
//MARK: - Functions
    
    /// A helper function, to make it easier to register for specific file types. The array should look like ["mp3", "aac", "psd"] etc.
    func registerForFileExtensions(extensions: [String]) {
        
        var types: [String] = []
        
        for ext in extensions {
            types.append("NSTypedFilenamesPboardType:\(ext)")
        }
        
        registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        acceptedFiles = extensions
        
    }
    
    /// Returns the file urls from the given DraggingInfo
    class func fileUrlsFromDraggingInfo(info: NSDraggingInfo) -> [NSURL]? {
        
        let pboard = info.draggingPasteboard
        
        if (pboard.types! as NSArray).contains(NSPasteboard.PasteboardType.string) {
            
            let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL]
            var realUrls = [NSURL]()
            
            for url in urls! {
                
                realUrls.append(url.filePathURL! as NSURL) // use filePathURL to avoid file:// file id's
                
            }
            
            return realUrls
            
        }
        
        return nil
        
    }
    
    /// Returns whether the dragginginfo has any valid files
    private func hasValidFiles(info: NSDraggingInfo) -> Bool {
        
        var hasValidFiles = false
        _ = info.draggingPasteboard
        
        let urls = DropZoneView.fileUrlsFromDraggingInfo(info: info)
        if urls == nil { return false }
        
        for url in urls! {
            
            if acceptedFiles.contains(url.pathExtension!) { hasValidFiles = true }

        }
        
        return hasValidFiles
        
    }

    
//MARK: - Dragging functions
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingEntered(_:))) {
            
            return dropDelegate!.draggingEntered!(sender)
            
        } else {
            
            if !hasValidFiles(info: sender) {
                return NSDragOperation.generic
            } else {
                return defaultDragOperation
            }
        
        }
        
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingUpdated(_:))) {
            
            return dropDelegate!.draggingUpdated!(sender)
            
        } else {
            
            if !hasValidFiles(info: sender) {
                return NSDragOperation.generic
            } else {
                return defaultDragOperation
            }
            
        }
        
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.draggingExited(_:))) {
            
            dropDelegate!.draggingExited!(sender!)
            
        }
        
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        if dropDelegate != nil && dropDelegate!.responds(to: #selector(NSDraggingDestination.prepareForDragOperation(_:))) {
            
            return dropDelegate!.prepareForDragOperation!(sender)
            
        }
        
        return true
        
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        if let del = dropDelegate {
            return del.performDragOperation(info: sender)
        }
        
        return true
        
    }
 
}
