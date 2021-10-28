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

// /Users/donghanhu/Documents/ScrapbookServerFolder

class CollectionViewMethodThree: NSViewController {
    
    @IBOutlet weak var webViewItem: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://www.apple.com") else{
            return
        }
        webViewItem.isHidden = true

//        webViewItem.load(URLRequest(url: url as URL))
        
        
        
        
        // /Users/donghanhu/Desktop/AR user study
        // /Users/donghanhu/Documents/ScrapbookServerFolder
        // /usr/sbin/screencapture
        // /usr/local/bin
        let command = "/usr/local/bin/node"
        var args = ["/Users/donghanhu/Documents/ScrapbookServerFolder", "server.js"]
        // var args = [String]()
        // args.append("/usr/bin/ls")
        
        // put node server in the default folder
        let defaultFoler = basicInformation.defaultFolderPathString
        
//        Optional("/usr/sbin/screencapture")
//        Optional(["-s", "/Users/donghanhu/Documents/ScrapbookServer/Screenshot-2021.10.19,01:01:31.jpg"])
        
        let output = startNodeJSServer(launchPath: command, arguments: args)
        print("output")
        print(output)
        // Do view setup here.
    }
    
    func startNodeJSServer(launchPath: String, arguments: [String]) -> String {
        let task = Process()
        let pipe = Pipe()
        
        
        task.launchPath = launchPath
        task.arguments = arguments
        
        print(type(of: task.launchPath))
        print(task.launchPath)
        print(task.arguments)
        
        // error: launch path not accessible
        
        task.standardOutput = pipe
        task.standardError = pipe
        
        do {
             try task.run()
                 // detect once mouse clicked
                 // mouseClick()
         } catch {
             print("something went wrong, error: \(error)")
         }
        
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        print("inside function, count is", output.count)
        if(output.count > 0){
            let lastIdnex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIdnex])
        }
        
        task.waitUntilExit()
        
        return output
    }
}
