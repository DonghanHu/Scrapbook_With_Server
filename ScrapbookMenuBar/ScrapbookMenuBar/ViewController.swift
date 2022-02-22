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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isHidden = true;

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

    @IBAction func selectedAreaCapture(_ sender: Any) {
        do {
            try self.view.window!.close()
        } catch  {
            print("the menu bar window is not closed successfully.")
        }
        
        let secondsToDelay = 0.5
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
    }
    
    @objc func takeWholeScreenshotFunction(){
        let takeScreenshotHandler = Screencapture()
        takeScreenshotHandler.wholeScreenCapture()
    }
    
    @IBAction func collectionViewMethodTwoAction(_ sender: Any) {
        
        // better method
        let viewController : NSViewController = collectionViewMethodTwoVC()
        let subWindow = NSWindow(contentViewController: viewController)
        let subWindowController = NSWindowController(window: subWindow)
        subWindowController.showWindow(nil)
        
//        let viewController : NSViewController = CapturedViewWiondow()
//        let subWindow = NSWindow(contentViewController: viewController)
//        let subWindowController = NSWindowController(window: subWindow)
//        subWindowController.showWindow(nil)
        
        // presentAsModalWindow(collectionViewMethodTwoVC())
        
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
    
    
    
}

