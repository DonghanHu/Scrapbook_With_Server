//
//  collectionViewMethodTwoVC.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 10/4/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa
import WebKit

class collectionViewMethodTwoVC: NSViewController, WKUIDelegate {

    @IBOutlet weak var webViewItem: WKWebView!
    
    var enableDeveloperTools: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.window?.level = .modalPanel
        
        self.webViewItem.uiDelegate = self
        
        webViewItem.configuration.preferences.setValue(enableDeveloperTools, forKey: "developerExtrasEnabled")
        webViewItem.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        self.view.frame.size.width = CGFloat(1250.0)
        self.view.frame.size.height = CGFloat(850.0)
        
        
        print(basicInformation.jsonFilePathURL!)
        self.title = "Collection View"
        guard let defaultURL = URL(string: "http://127.0.0.1:8080/collectionView.html") else{
            return
        }
        print(defaultURL)
        let requesturl = defaultURL
        let request = URLRequest(url: requesturl)
        webViewItem.load(request)
        
        
        
        
        
        
        // Do view setup here.
    }
    
    func webView(_ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void) {
        
        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.informativeText = message
        alert.addButton(withTitle: "Ok")

        // Display the NSAlert
        alert.runModal()

        // Call completionHandler
        completionHandler()
    }
    
    func webView(_ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void) {

        // Set the message as the NSAlert text
        let alert = NSAlert()
        alert.informativeText = message

        // Add a confirmation button “OK”
        // and cancel button “Cancel”
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        // Display the NSAlert
        let action = alert.runModal()

        // Call completionHandler with true only
        // if the user selected OK (the first button)
        completionHandler(action == .alertFirstButtonReturn)
    }

    // end of the class
}

