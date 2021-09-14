//
//  ViewController.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/30/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet weak var takeSelectedScreenshot: NSButton!
    @IBOutlet weak var takeWholeScreenshot: NSButton!
    @IBOutlet weak var collectionView: NSButton!
    @IBOutlet weak var quitScrapbook: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectedAreaCapture(_ sender: Any) {
        do {
            try self.view.window?.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
        }
        
//        let csvFilesOperationsHandler = csvFilesOperations()
//        csvFilesOperationsHandler.readCSVFile(filePath: "AppleScripts")
        
        let takeScreenshotHandler = Screencapture()
        takeScreenshotHandler.selectScreenCapture()
        print("click button: take screenshot for a selected area.")
        
    }
    
    @IBAction func wholeScreenCapture(_ sender: Any) {
        do {
            try self.view.window?.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
        }
        do{
            sleep(1)
        }
        
        let takeScreenshotHandler = Screencapture()
        takeScreenshotHandler.wholeScreenCapture()
        print("click button: take screenshot for the whole screen.")
    }
    
    
    @IBAction func quitScrapbookFunc(_ sender: Any) {
        exit(0);
    }
    
}

