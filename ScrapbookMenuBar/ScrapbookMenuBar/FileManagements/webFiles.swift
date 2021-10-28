//
//  webFiles.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 10/27/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

class webFiles : NSObject{
    
    func createHTMLFile(filepath: URL) {
        let documentsDirectoryPath = filepath
        
        // create the name for index.html
        let HTMLFilePath = documentsDirectoryPath.appendingPathComponent("index.html")
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (HTMLFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (HTMLFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("HTML file created successfully!")
                writeInitialWebFileData(Filepath: (HTMLFilePath.absoluteString), fileName: "index", type: "html")
                
            } else {
                print("Couldn't create HTML file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("HTML file is already existed!")
        }
    }
    
    func createCSSFile(filepath: URL) {
        let documentsDirectoryPath = filepath
        
        // create the name for index.html
        let CSSFilePath = documentsDirectoryPath.appendingPathComponent("styles.css")
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (CSSFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (CSSFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("CSS file created successfully!")
                writeInitialWebFileData(Filepath: (CSSFilePath.absoluteString), fileName: "styles", type: "css")
                
            } else {
                print("Couldn't create CSS file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("CSS file is already existed!")
        }
    }
    
    func createJavaScriptFile(filepath: URL) {
        let documentsDirectoryPath = filepath
        
        // create the name for index.html
        let JavaScriptFilePath = documentsDirectoryPath.appendingPathComponent("javascript.js")
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (JavaScriptFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (JavaScriptFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("CSS file created successfully!")
                writeInitialWebFileData(Filepath: (JavaScriptFilePath.absoluteString), fileName: "javascript", type: "js")
                
            } else {
                print("Couldn't create CSS file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("CSS file is already existed!")
        }
    }
    
    
    func writeInitialWebFileData(Filepath : String, fileName : String, type : String){
        
        let htmlContent = Bundle.main.path(forResource: fileName, ofType: type)
        do {
            var strHTMLContent = try String(contentsOfFile: htmlContent!)
            print(strHTMLContent)
            if FileManager.default.fileExists(atPath: Filepath){
                if let fileHandle = FileHandle(forWritingAtPath: Filepath){
                    let data = strHTMLContent.data(using: .utf8)!
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
                else {
                    let nsError = NSError()
                    let errorMessage = nsError.localizedDescription
                    print("Can't open fileHandle" + errorMessage)
                }
            }
            
        }catch let err{
            print("html file content: \(err).")
        }
        

    }
}
