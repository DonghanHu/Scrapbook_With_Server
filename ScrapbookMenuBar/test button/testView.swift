//
//  testView.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 2/22/22.
//  Copyright © 2022 Donghan Hu. All rights reserved.
//

import Cocoa
import WebKit
import Foundation
import AppKit

class testView: NSViewController {
    
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
        // runApplescript(applescript: openSafari)
        
//        guard let defaultURL = URL(string: "http://www.apple.com") else{
//            return
//        }
//        print(defaultURL)
//        let requesturl = defaultURL
//        let request = URLRequest(url: requesturl)
//        webViewTest.load(request)
        
        // create a test json file
        let createTestFileHandler = createTestFile();
        createTestFileHandler.creaetTestJsonFile(filepath: basicInformation.defaultFolderPathURL!)
        // createTestFileHandler.clearTempJsonFile(FilePath:  basicInformation.defaultFolderPathString)
        // testFilePathString testFilePathURL
        
    }

    
    @IBAction func clickButton(_ sender: Any) {
        
//        let task = Process()
//        task.launchPath = "/usr/sbin/screencapture"
        let launchPathStr = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-s")
        
        let tempScreenshotPath = "/Users/donghanhu/Documents/ScrapbookServer/Public/Data/1.jpeg"
        arguments.append(tempScreenshotPath)
        
        takeScreenshotFun(launchPath: launchPathStr, args:  arguments)
        // getPortNumberPID(launchPath: launchPathStr, args:  arguments)
        
    }
    func getPortNumberPID(launchPath: String, args : [String]) -> String{
        var output : [String] = []
        var res = String()
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            let outdata = pipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .ascii) {
            // if var string = String(data: outdata, encoding: .utf8) {
                print("string: " + string)
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            let len = output.count
            print("output len is: ", len)
        } catch {
            print("something went wrong \(error)")
        }
        
        print("ARRAY: ", output)
        let stringRepresentation = output.joined(separator:"-")
        task.waitUntilExit()
        pipe.fileHandleForReading.closeFile()
        print("get port number process: ", task.isRunning)
        dialogOK(question: stringRepresentation, text: "Click OK to continue.")
        return res
    }
    
    func takeScreenshotFun(launchPath: String, args : [String]) -> String{
        
        var output : [String] = []
        var res = String()
        var finalOutputData : String = ""
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
        
        do{
            try task.run()
        } catch{
            print("\(error)")
        }
        let pipeFile = outpipe.fileHandleForReading
        let data = pipeFile.readDataToEndOfFile()
        task.waitUntilExit()
        
        
        
        
        let tempResult = String(data: data, encoding: .ascii)!
        let rawResults = tempResult.components(separatedBy:"\"")
            
        print("ARRAY: ", rawResults)

        finalOutputData = tempResult
        print("finalOutputData", tempResult)
        
        dialogOK(question: finalOutputData, text: "Click OK to continue.")
        
        do {
            try writeTempJsonData(targetString: finalOutputData)
        }
        catch {print("\(error)")}
        
        //
        do {
            try writeTempJsonData(targetString: tempResult)
        }
        catch {print("\(error)")}
        
        return finalOutputData
        
    }
    func writeTempJsonData(targetString: String){
        let path = basicInformation.testFilePathString
        print("testPath: " + path)
        
        print(type(of: basicInformation.testFilePathURL))
        print(basicInformation.testFilePathURL)
        var filePath = "file://\(path)"
        print(filePath)
        let fileUrl = URL(string: filePath)
        do {
            try targetString.write(to: fileUrl!, atomically: false, encoding: .utf8)
        }
        catch {print("\(error)")}
        
        
    }
    
    func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
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
