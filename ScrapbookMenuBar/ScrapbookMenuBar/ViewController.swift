//
//  ViewController.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/30/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet weak var takeSelectedScreenshot: NSButton!
    @IBOutlet weak var takeWholeScreenshot: NSButton!
    @IBOutlet weak var collectionView: NSButton!
    @IBOutlet weak var quitScrapbook: NSButton!
    @IBOutlet weak var collectionViewMethodTwo: NSButton!
    @IBOutlet weak var testButton: NSButton!
    
    var openSafariScript =
    """
    tell application "Safari"
        activate
        tell window 1
            open location "http://localhost:8080/collectionView.html"
            set bounds to {100, 30, 1400, 850}
        end tell
    end tell
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isHidden = true;
        testButton.isHidden = false

        takeSelectedScreenshot.title = "Take Selected Area Screenshot"
        takeWholeScreenshot.title = "Take Whole Screen Screenshot"
        collectionView.title = "Collection View"
        quitScrapbook.title = "Quit Scrapbook"
        collectionViewMethodTwo.title = "Collection View"
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    // first button
    @IBAction func selectedAreaCapture(_ sender: Any) {
        do {
            try self.view.window!.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
        }
        
        let secondsToDelay = 0.7
        perform(#selector(takeSelectedScreenshotFunction), with: nil, afterDelay: secondsToDelay)

        print("click button: take screenshot for a selected area.")
        
    }
    
    @IBAction func wholeScreenCapture(_ sender: Any) {
        
        do {
           try self.view.window!.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
            print("Unexpected error in wholeScreenCapture: \(error).")
        }
//        do{
//            sleep(1)
//        }
        let secondsToDelay = 1.0
        perform(#selector(takeWholeScreenshotFunction), with: nil, afterDelay: secondsToDelay)

        print("click button: take screenshot for the whole screen.")
    }
    

    @objc func takeSelectedScreenshotFunction(){
        let takeScreenshotHandler = Screencapture()
        takeScreenshotHandler.selectScreenCapture()
//        let docPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let imagePath = docPath.appending("/"+"Screenshot-TEST.jpg")
//
//        print("imagePath: ", imagePath)
//        let task = Process()
//        let pipe = Pipe()
//
//        task.launchPath = "/usr/sbin/screencapture"
//        task.arguments = ["-s", imagePath]
//        task.standardOutput = pipe
//        task.standardError = pipe
//        task.launch()
//
//        let fileHandle = pipe.fileHandleForReading
//        let resultString = String(data: fileHandle.readDataToEndOfFile(), encoding: .ascii)
//        let rawResult = resultString?.components(separatedBy: "\"")
//        var tempResult = [AnyHashable](repeating: 0, count: 20)
//        var i = 0
//        while i <= rawResult!.count - 2 {
//            if ((rawResult!.count - 1) < i + 1) {
//                //
//            } else {
//                tempResult.append(rawResult![i+1])
//            }
//            i += 2
//        }
//
//        dialogOK(question: resultString!, text: "TEST")
//        print("Result: ", rawResult)
    }
    
    func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @objc func takeWholeScreenshotFunction(){
        let takeScreenshotHandler = Screencapture()
        takeScreenshotHandler.wholeScreenCapture()
    }
    
    @IBAction func collectionViewMethodTwoAction(_ sender: Any) {
        
        runApplescript(applescript: openSafariScript)
        
        self.view.window?.close()
    }
    
    @IBAction func quitScrapbookFunc(_ sender: Any) {
        var checkPIDArgs = [String]()
        //lsof -i tcp:8080
        checkPIDArgs.append("-i")
        checkPIDArgs.append("tcp:8080")
        
        let PIDNumber = getPortNumberPID(launchPath: "/usr/sbin/lsof", args: checkPIDArgs)
        // print("PID number is: ", PIDNumber)

        // kill -9 port number
        var killPortArgs = [String]()
        killPortArgs.append("-9")
        killPortArgs.append(PIDNumber)
        KillPortNumber(launchPath: "/bin/kill", args: killPortArgs)
        
        exit(0);
    }
    
    
    @IBAction func openTestView(_ sender: Any) {
        
        do {
           try self.view.window!.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
            print("Unexpected error in test butoon action: \(error).")
        }
        
        let secondsToDelay = 1.0
        perform(#selector(cropScreenshotAction), with: nil, afterDelay: secondsToDelay)
        
        print("clicked the test button")
        
    }
    
    @objc func cropScreenshotAction(){
        

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd,HH-mm-ss"
        let dateString = dateFormatter.string(from: date)
        let screenshotPicName = "Screenshot-" + dateString + ".jpeg"
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        print(capturedScreenshotInformation.capturedScreenshotPathString)
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)
        
        // comment these code
//        var simpleWholeInfor = ""
//        var screenshotStruct = screenshotInformation()
//        screenshotStruct.metaDataSingleRecordingTemplate["TimeStamp"] = dateString
//        screenshotStruct.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = false
        let screenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
//        screenshotStruct.metaDataSingleRecordingTemplate["ImagePath"] = screenshotPathString
//        screenshotStruct.metaDataSingleRecordingTemplate["ScreenshotPictureName"] = screenshotPicName
//        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = [] as! [[String : Any]]
        
//        print("screenshotStruct is: ", screenshotStruct)
        // till here
        
        fromCropScreenshot.timeStamp = dateString
        fromCropScreenshot.imagePath = screenshotPathString
        fromCropScreenshot.screenshotFileName = screenshotPicName
        
        
        let imagePath = capturedScreenshotInformation.capturedScreenshotPathString

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-x")
        arguments.append(imagePath)
        task.arguments = arguments
        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
        //task.launch() // asynchronous call.
        do {
            try task.run()
        } catch {
            print("something went wrong")
        }
        task.waitUntilExit()
        // wait until the task is finished
        let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        let resultInformation = String(data: outputData, encoding: .utf8)
        print("information from pipe: ", resultInformation)
        
        tempCropScreenshotPath = imagePath
        
        // after taking a screenshot, get NSimage from the path, and obtain corresponding data 
        
        let viewController : NSViewController = croppingImage()
        let subWindow = NSWindow(contentViewController: viewController)
        let subWindowController = NSWindowController(window: subWindow)
        subWindowController.showWindow(nil)
    }
    
    func getPortNumberPID(launchPath: String, args : [String]) -> String{
        
        var output : [String] = []
        var res = String()
        
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        do {
            try task.run()
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            let len = output.count
            // print("output len is: ", len)
            // len is 2
            if(len > 1){
                let strs = output[1].split(separator: " ")
                res = String(strs[1])
                for i in 0..<strs.count{
                    // the second element is pid number
                    print(i, strs[i])
                }
            }
            // print("get port number process: ", task.isRunning)
        } catch {
            print("something went wrong \(error)")
        }
        task.waitUntilExit()
        // print("get port number process: ", task.isRunning)
        
        return res
    }
    
    func KillPortNumber(launchPath: String, args : [String]){
        var output : [String] = []
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args
        let outpipe = Pipe()
        task.standardOutput = outpipe
        do {
            try task.run()
            let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
            if var string = String(data: outdata, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            let len = output.count
            if(len > 0){
                for i in 0..<len{
                    print(i, output[i])
                }
            }
            // print("kill port number process: ", task.isRunning)
        } catch {
            print("something went wrong \(error)")
        }
        task.waitUntilExit()
        // print("kill port number process: ", task.isRunning)
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

