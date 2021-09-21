//
//  CapturedViewWiondow.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 9/20/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa

class CapturedViewWiondow: NSViewController {

    // image display item: nsimageview
    @IBOutlet weak var displayScreenshot: NSImageView!
    // memo information: title and text
    @IBOutlet weak var memoTitle: NSTextField!
    @IBOutlet weak var memoText: NSTextField!
    // labels for displaying information and meta-data
    @IBOutlet weak var applicationNameLabel: NSTextField!
    @IBOutlet weak var applicationCategoryLabel: NSTextField!
    @IBOutlet weak var metadataOneLabel: NSTextField!
    @IBOutlet weak var metadataTwoLabel: NSTextField!
    // save and delete screenshot button
    @IBOutlet weak var deleteScreenshotButton: NSButton!
    @IBOutlet weak var saveScreenshotButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
