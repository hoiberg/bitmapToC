//
//  ViewController.swift
//  Bitmapper
//
//  Created by Alex on 01-03-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, DropZoneDelegate {

    @IBOutlet var dropView: DropZoneView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var dragHereLabel: NSTextField!
    @IBOutlet weak var bitsBox: NSComboBox!
    
    var selectedImage: NSImage?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // setup dropView
        dropView.registerForFileExtensions(extensions: ["bmp"])
        dropView.defaultDragOperation = .copy
        dropView.dropDelegate = self
        
    }
    
    override func viewWillAppear() {
        
        // setup textView
        textView.font = NSFont(name: "Menlo", size: 11)
        
    }
    
    private func getImageFromURL(url: NSURL) {
        
        if url.pathExtension! == "bmp" {
            
            // change selectedImage
            selectedImage = NSImage(contentsOf: url as URL)
            
            // UI
            imageView.image = selectedImage
            dragHereLabel.isHidden = true
            
            // update window title
            view.window!.title = "Bitmap to C array: \(url.lastPathComponent!) (width: \(Int(selectedImage!.size.width)) height: \(Int(selectedImage!.size.height)))"
            
        }

    }
    
    private func valueForColor(color: NSColor) -> Int {
        // if it is dark, return 1, and if it is light, return 0
        return color.whiteComponent < 0.5 ? 1 : 0
//        return color.brightnessComponent < 0.5 ? 1 : 0
    }
    
    func performDragOperation(info: NSDraggingInfo) -> Bool {
        
        let urls = DropZoneView.fileUrlsFromDraggingInfo(info: info)
        
        if urls != nil && urls!.count > 0 {
            
            getImageFromURL(url: urls![0])
            
        }
        
        return true
        
    }
    
    @IBAction func convertBitmapToC(sender: AnyObject) {
        
        if let img = selectedImage {
            
            // get neccesary data: bitmaprep & dimensions
            let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
            let height = Int(img.size.height)
            let width = Int(img.size.width)
        
            // amount of pixel values in one array item
            let bitsPerItem = bitsBox.integerValue
            if bitsPerItem == 0 { return }
            
            // output string
            var output = "// width: \(width) height: \(height)\nPROGMEM const unsigned char YOUR_NAME[] = {\n\(width), \(height),"
            
            // y loop
            for row in 0 ..< height {
                
                output += "\n" // add line break
                var currentValue = 0 // the current array item
                var posInCurrentValue = 0 // current bit in current array item
                
                // x loop
                for col in 0 ..< width {
                    
                    // add 1 or 0 at correct position in currentValue
                    let lsl = bitsPerItem - posInCurrentValue - 1
                    let bit = valueForColor(color: rep.colorAt(x: col, y: row)!) << lsl
                    currentValue += bit
                    
                    
                    posInCurrentValue += 1
                    
                    if posInCurrentValue == bitsPerItem {
                        
                        // add to output string as hexadecimal with at least two digits, it still looks messy with more than 8 bits per array item
                        let valueString = String(currentValue, radix: 16)
                        output += valueString.count == 1 && bitsPerItem > 4 ? "0x0\(valueString)" : "0x\(valueString)"

                        // if it isn't the last object, add a comma
                        if row != height-1 || col != width-1 { output += ", " }
                        
                        // reset
                        currentValue = 0
                        posInCurrentValue = 0
                        
                    }
                    
                }
                
                
            }
            
            // finish array
            output += "\n\n};"
            
            // show it to the user
            textView.string = output
            
        }
        
    }

    @IBAction func openFile(sender: AnyObject) {
        
        // show open panel
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["bmp"]
        
        panel.begin( completionHandler: { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                
                self.getImageFromURL(url: panel.url! as NSURL)
                
            }
        })
        
    }

    @IBAction func copyOutput(sender: AnyObject) {
        
        // copy contents of textView to generalPasteBoard
        let pasteBoard = NSPasteboard.general
        pasteBoard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteBoard.setString(textView.string, forType: NSPasteboard.PasteboardType.string)
        
    }
}

