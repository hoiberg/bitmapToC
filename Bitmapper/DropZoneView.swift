//
//  DropZoneView.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

@objc protocol DropZoneDelegate: NSObjectProtocol, NSDraggingDestination {
    
    /// Redirect of the draggingEntered function (optional)
    optional func draggingEntered(info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingUpdated function (optional)
    optional func draggingUpdated(info: NSDraggingInfo) -> NSDragOperation
    
    /// Redirect of the draggingExited function (optional)
    optional func draggingExited(info: NSDraggingInfo)
    
    /// Redirect of the prepareForDragOperation (optional)
    optional func prepareForDragOperation(info: NSDraggingInfo) -> Bool
    
    /// Redirect of the performDragOperations (required)
    func performDragOperation(info: NSDraggingInfo) -> Bool
    
}

class DropZoneView: NSView {

//MARK: - Instance variables
    
    @IBOutlet var dropDelegate: DropZoneDelegate?
    
    /// The array holding the file extensions that are accepted (e.g. ["mp3", "aac"])
    var acceptedFiles: [String] = []
    
    /// The dragOperation that will de returned if an optoinal DropZoneDelegate function has not been implemented
    var defaultDragOperation = NSDragOperation.Copy
    
    
//MARK: - Functions
    
    /// A helper function, to make it easier to register for specific file types. The array should look like ["mp3", "aac", "psd"] etc.
    func registerForFileExtensions(extensions: [String]) {
        
        var types: [String] = []
        
        for ext in extensions {
            types.append("NSTypedFilenamesPboardType:\(ext)")
        }
        
        registerForDraggedTypes([NSFilenamesPboardType])
        acceptedFiles = extensions
        
    }
    
    /// Returns the file urls from the given DraggingInfo
    class func fileUrlsFromDraggingInfo(info: NSDraggingInfo) -> [NSURL]? {
        
        let pboard = info.draggingPasteboard()
        
        if (pboard.types! as NSArray).containsObject(NSURLPboardType) {
            
            var urls = pboard.readObjectsForClasses([NSURL.self], options: nil) as? [NSURL]
            var realUrls = [NSURL]()
            
            for url in urls! {
                
                realUrls.append(url.filePathURL!) // use filePathURL to avoid file:// file id's
                
            }
            
            return realUrls
            
        }
        
        return nil
        
    }
    
    /// Returns whether the dragginginfo has any valid files
    private func hasValidFiles(info: NSDraggingInfo) -> Bool {
        
        var hasValidFiles = false
        let pboard = info.draggingPasteboard()
        
        var urls = DropZoneView.fileUrlsFromDraggingInfo(info)
        if urls == nil { return false }
        
        for url in urls! {
            
            if contains(acceptedFiles, url.pathExtension!) { hasValidFiles = true }
                
        }
        
        return hasValidFiles
        
    }

    
//MARK: - Dragging functions
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.respondsToSelector(Selector("draggingEntered:")) {
            
            return dropDelegate!.draggingEntered!(sender)
            
        } else {
            
            if !hasValidFiles(sender) {
                return NSDragOperation.None
            } else {
                return defaultDragOperation
            }
        
        }
        
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        
        if dropDelegate != nil && dropDelegate!.respondsToSelector(Selector("draggingUpdated:")) {
            
            return dropDelegate!.draggingUpdated!(sender)
            
        } else {
            
            if !hasValidFiles(sender) {
                return NSDragOperation.None
            } else {
                return defaultDragOperation
            }
            
        }
        
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        
        if dropDelegate != nil && dropDelegate!.respondsToSelector(Selector("draggingExited:")) {
            
            dropDelegate!.draggingExited!(sender!)
            
        }
        
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        
        if dropDelegate != nil && dropDelegate!.respondsToSelector(Selector("prepareForDragOperation:")) {
            
            return dropDelegate!.prepareForDragOperation!(sender)
            
        }
        
        return true
        
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        if let del = dropDelegate? {
            return dropDelegate!.performDragOperation(sender)
        }
        
        return true
        
    }
 
}
