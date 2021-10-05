//
//  collectionViewMethodTwoVC.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 10/4/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa
import WebKit

class collectionViewMethodTwoVC: NSViewController {

    @IBOutlet weak var webViewItem: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://www.apple.com") else{
            return
        }
        // webViewItem.load(URLRequest(url: url))
        
        let urlpath = Bundle.main.url(forResource: "index", withExtension: "html")
        
        print(urlpath)
        let requesturl = urlpath
        let request = URLRequest(url: requesturl!)
        webViewItem.load(request)
        
        
        // Do view setup here.
    }
    
    
}
