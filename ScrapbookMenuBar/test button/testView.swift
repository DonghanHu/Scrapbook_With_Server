//
//  testView.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 2/22/22.
//  Copyright © 2022 Donghan Hu. All rights reserved.
//

import Cocoa
import WebKit

class testView: NSViewController {
    @IBOutlet weak var webViewTest: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let openSafari =
        """
        tell application "Safari"
            activate
            tell window 1
                open location "http://localhost:8080/collectionView.html"
                set bounds to {100, 30, 1400, 850}
            end tell
        end tell
        """
        runApplescript(applescript: openSafari)
        
        
        guard let defaultURL = URL(string: "http://www.apple.com") else{
            return
        }
        print(defaultURL)
        let requesturl = defaultURL
        let request = URLRequest(url: requesturl)
        webViewTest.load(request)
    }
    
    func runApplescript(applescript : String) -> String{
        let tempStr = String(applescript)

        let validString = tempStr.replacingOccurrences(of: "\\n", with: "\n")
        print("validString")
        print(validString)
        var error: NSDictionary?
        
        let scriptObject = NSAppleScript(source: validString)
        let output: NSAppleEventDescriptor = scriptObject!.executeAndReturnError(&error)
        // print("output", output)
        if (error != nil) {
            print("error: \(String(describing: error))")
        }
        if output.stringValue == nil{
            let empty = "the result is empty"
            return empty
        }
        else {
            return (output.stringValue?.description)!
            
        }
    }
}
