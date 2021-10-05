//
//  CollectionViewMethodThree.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 10/4/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa
import WebKit
import AppKit
import Foundation


class CollectionViewMethodThree: NSViewController {
    
    @IBOutlet weak var webViewItem: WKWebView!
    
    let url = NSURL(string: "http://www.google.com/")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webViewItem.load(URLRequest(url: url as URL))
        
        // Do view setup here.
    }
}
