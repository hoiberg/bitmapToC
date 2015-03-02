//
//  DropZoneView.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

@objc protocol DropZoneDelegate: NSObjectProtocol, NSDraggingDestination {
    
    optional func draggingEntered(info: NSDraggingInfo) -> NSDragOperation
    optional func draggingUpdated(info: NSDraggingInfo) -> NSDragOperation
    optional func draggingExited(info: NSDraggingInfo)
    optional func prepareForDragOperation(info: NSDraggingInfo) -> Bool
    func performDragOperation(info: NSDraggingInfo) -> Bool
    
}

class DropZoneView: NSView {
    
    var dropDelegate: DropZoneDelegate?
    var acceptedFiles: [String] = []
    var defaultDragOperation = NSDragOperation.Copy
    
    func registerForFileExtensions(extensions: [String]) {
        
        var types: [String] = []
        
        for ext in extensions {
            
            types.append("NSTypedFilenamesPboardType:\(ext)")
            
        }
        
        registerForDraggedTypes([NSFilenamesPboardType])
        acceptedFiles = extensions
        
    }
    
    private func hasValidFiles(info: NSDraggingInfo) -> Bool {
        
        var hasValidFiles = false
        
        let pboard = info.draggingPasteboard()
        
        var urls = DropZoneView.fileUrlsFromDraggingInfo(info)
        
        if urls == nil { return false }
        
        for url in urls! {
            
            
            if contains(acceptedFiles, url.pathExtension!) {
                hasValidFiles = true
            }
                
        }
        
        return hasValidFiles
        
    }
    
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
    
    class func fileUrlsFromDraggingInfo(info: NSDraggingInfo) -> [NSURL]? {
        
        let pboard = info.draggingPasteboard()
        
        if (pboard.types! as NSArray).containsObject(NSURLPboardType) {
            
            var urls = pboard.readObjectsForClasses([NSURL.self], options: nil) as? [NSURL]
            var realUrls = [NSURL]()
            
            for url in urls! {
                
                realUrls.append(url.filePathURL!)
                
            }
            
            return realUrls
            
        }
        
        return nil
        
    }


 
}
