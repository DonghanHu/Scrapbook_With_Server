//
//  AppDelegate.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/30/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

struct basicInformation {
    static var defaultFolderPathString              =   ""
    static var defaultFolderPathURL                 =   URL(string: "default_folder_path")
    static var jsonFilePathURL                      =   URL(string: "default_jsonFile_path")
    static var jsonFilePathString                   =   ""
    
    static var tempScreenshotJsonFilePathString     =   ""
    static var tempScreenshotJsonFilePathURL        = URL(string: "temp_jsonFile_Path")
}

struct capturedScreenshotInformation {
    static var capturedScreenshotPathString         =   ""
    static var capturedScreenshotPathURL            =   URL(string: "default_image_path")
    static var capturedApplicationNameArray         =   [String]()
    static var capturedScreenshotWidth              =   Int()
    static var capturedScreenshotHeight             =   Int()
}

struct tempScreenshotInformationStruct {
    static var dataDictionary = [String : Any]()
    static var capturedApplicationNameArray = [String]()
}

struct screenshotInformation{
    var metaDataSingleRecordingTemplate : [String : Any] = [
        
        "Index"                     : Int(),
        "TimeStamp"                 : String(),
        "AppInforString"            : String(),

        "WholeScreenshotOrNot"      : false,
        "CaptureRegion"             : [String : Int](),
        "ImagePath"                 : String(),
        "ScreenshotPictureName"     : String(),
        "ApplicationInformation"    : [[String : Any]](),
        "ScreenshotTitle"           : String(),
        "ScreenshotText"            : String()
    ]
    
}

struct screenshotCaptureRegion {
    var screenshotRegion : [String : Int] = [
        "Width"                     : Int(),
        "Height"                    : Int(),
        "Left"                      : Int(),
        "Top"                       : Int(),
        "Right"                     : Int(),
        "Bottom"                    : Int()
    ]
    
    init(left : Int, top : Int, right : Int, bottom : Int, width : Int, height : Int){
        self.screenshotRegion["Width"]  = width
        self.screenshotRegion["Height"] = height
        self.screenshotRegion["Left"]   = left
        self.screenshotRegion["Top"]    = top
        self.screenshotRegion["Right"]  = right
        self.screenshotRegion["Bottom"] = bottom
    }
}

struct applicationInformation{
    var singleApplicationInforTemplate       : [String : Any] = [
        "ApplicationName"           : String(),
        "ApplicationNameWithRank"   : String(),
        "Category"                  : String(),
        "Left"                      : Int(),
        "Top"                       : Int(),
        "Right"                     : Int(),
        "Bottom"                    : Int(),
        "Rank"                      : String(),
        "FirstMetaData"             : String(),
        "SecondMetaData"            : String()
    ]
}

struct nodeServerTasks{
    static var nodeTask = Process()
    static var nodePipe = Pipe()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let jsonFileHandler = jsonFile()
    let webFileHandler = webFiles()
    let tempJsonFileHandler = tempJsonFileOperations()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "S"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        
        // create default folder and json file in the Document
        
        let defaultFolderPath = getHomePath() + "/Documents/" + "ScrapbookServer/public/Data/"
        basicInformation.defaultFolderPathString = defaultFolderPath
        basicInformation.defaultFolderPathURL = URL(string: basicInformation.defaultFolderPathString)

        // create a default folder for saving json file and screenshots
        checkDefaultFolder(folderPath: defaultFolderPath)
        
        // create json file
        jsonFileHandler.createJson(filepath: basicInformation.defaultFolderPathURL!)
        
        // create temp json file to save temp screenshot's informatin
        tempJsonFileHandler.tempJson(filepath : basicInformation.defaultFolderPathURL!)
        
        // take a testing screenshot while launching the application for asking request
        takeTestingImage()
        deleteTestingImage()
        
        
        // creating web files
        let webFolderPathString = getHomePath() + "/Documents/ScrapbookServer/public/"
        let webFolderPathURL = URL(string: webFolderPathString)!
        // comment functions that create web files
//        webFileHandler.createHTMLFile(filepath: webFolderPathURL)
//        webFileHandler.createCSSFile(filepath: webFolderPathURL)
//        webFileHandler.createJavaScriptFile(filepath: webFolderPathURL)
        
        var checkPIDArgs = [String]()
        //lsof -i tcp:8080
        checkPIDArgs.append("-i")
        checkPIDArgs.append("tcp:8080")
        let PIDNumber = getPortNumberPID(launchPath: "/usr/sbin/lsof", args: checkPIDArgs)
        
        
        // print("PID number is: ", PIDNumber)
        
        // kill the 8080 port
        // this one does not work
        // kill -9 port number
        var killPortArgs = [String]()
        killPortArgs.append("-9")
        killPortArgs.append(PIDNumber)
        KillPortNumber(launchPath: "/bin/kill", args: killPortArgs)
        
        // dispatch queue for test
//        DispatchQueue.global(qos: .utility).async {
//            for i in 0...5{
//                print(i)
//            }
//        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let command = "/usr/local/bin/node"
            let args = ["/Users/donghanhu/Documents/ScrapbookServerFolder", "server.js"]
            self.runCommandLine(launchPath: command, arguments: args)
        }

        
        // Insert code here to initialize your application
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
    
    func runCommandLine(launchPath: String, arguments: [String]){
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
    
        // print("tash launch path: " + launchPath)
        // print("task arguments:", arguments)
        
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        print(task.isRunning)


        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
        if(output.count > 0){
            let lastIdnex = output.index(before: output.endIndex)
            print(String(output[output.startIndex ..< lastIdnex]))
        }
        print("task" + launchPath + "is running? " + String(task.isRunning))
        
    }
    
    func testFunc(){
        print("THis is the test function")
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @objc func showSettings() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find Viewcontroller in the story board.")
        }
        
        guard let button = statusItem.button else {
            fatalError("could not find status item button.")
        }
        
        let popoverView = NSPopover()
        popoverView.contentViewController = vc
        popoverView.behavior = .transient
        popoverView.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        
    }

    @objc func getHomePath() -> String{
        let pw = getpwuid(getuid())
        let home = pw?.pointee.pw_dir
        let homePath = FileManager.default.string(withFileSystemRepresentation: home!, length: Int(strlen(home!)))
        return homePath
    }
    
    @objc func checkDefaultFolder(folderPath : String) {
        if FileManager.default.fileExists(atPath: folderPath){
            print("default is already existed!")
        }
        else {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                print(folderPath)
                print("default folder created successfully!")
            } catch {
                
                print("default folder created failed!")
                print(error)
            }
        }

    }
    
    
    func takeTestingImage(){
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-x")

        arguments.append(basicInformation.defaultFolderPathString + "Testing.jpg")
        task.arguments = arguments

        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
         do {
           try task.run()
         } catch {}
        
        task.waitUntilExit()
        print("taking a test image is finished")
    }
    
    func deleteTestingImage(){
        let path = basicInformation.defaultFolderPathString  + "Testing.jpg"
        do {
          try FileManager.default.removeItem(atPath: path)
        } catch{
            print("error iin delete the testing image: \(error)")
        }
        
    }
    
    // end of the class AppDelegate

}



