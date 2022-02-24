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
        // runApplescript(applescript: openSafari)
        
        
        guard let defaultURL = URL(string: "http://www.apple.com") else{
            return
        }
        print(defaultURL)
        let requesturl = defaultURL
        let request = URLRequest(url: requesturl)
        webViewTest.load(request)
    }
    @IBAction func clickButton(_ sender: Any) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-s")
        
        let tempScreenshotPath = "/Users/donghanhu/Documents/ScrapbookServer/Public/Data/1.jpg"
        arguments.append(tempScreenshotPath)
        task.arguments = arguments
        print(task.launchPath)
        print(task.arguments)
        
        let outpipe = Pipe()
        // let errorOutPipe = Pipe()
        
        var finalOutputData : String = ""
        
        
        task.standardOutput = outpipe
        // task.standardError = outpipe

        //task.launch() // asynchronous call.
        do {
            try task.run()
        } catch {
            print("something went wrong in task of taking screenshot \(error)")
        }
        let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        
        let tempResult = String(data: outputData, encoding: .utf8)
        finalOutputData = tempResult!
        print("finalOutputData", tempResult!)
        
        
    }
    func TakeScreensShots(folderName: String){
        
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success) {
            print("error: \(result)")
            return
        }
           
        for i in 1...displayCount {
            let unixTimestamp = CreateTimeStamp()
            let fileUrl = URL(fileURLWithPath: folderName + "\(unixTimestamp)" + "_" + "\(i)" + ".jpg", isDirectory: true)
            print(fileUrl)
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[Int(i-1)])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            
            
            do {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch {print("error: \(error)")}
        }
    }

    func CreateTimeStamp() -> Int32
    {
        return Int32(Date().timeIntervalSince1970)
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
