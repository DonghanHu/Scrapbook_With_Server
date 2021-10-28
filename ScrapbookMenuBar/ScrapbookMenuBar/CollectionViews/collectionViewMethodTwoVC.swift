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
        
        self.view.frame.size.width = CGFloat(700.0)
        self.view.frame.size.height = CGFloat(550.0)
        
        print(basicInformation.jsonFilePathURL!)
        
        guard let defaultURL = URL(string: "http://localhost:8081/") else{
            return
        }
        
        let urlpath = Bundle.main.url(forResource: "index", withExtension: "html")
        print(type(of: urlpath))
        print(urlpath!)
        

        
        let requesturl = urlpath
        let request = URLRequest(url: requesturl!)
        webViewItem.load(request)
        
        
        // Do view setup here.
    }
    // end of the class
}

