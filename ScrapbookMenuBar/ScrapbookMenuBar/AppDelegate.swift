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
}

struct capturedScreenshotInformation {
    static var capturedScreenshotPathString         =   ""
    static var capturedScreenshotPathURL            =   URL(string: "default_image_path")
    static var capturedApplicationNameArray         =   [String]()
    static var capturedScreenshotWidth              =   Int()
    static var capturedScreenshotHeight             =   Int()
}



struct screenshotInformation{
    var metaDataSingleRecordingTemplate : [String : Any] = [
        
        "Index"                     : Int(),
        "TimeStamp"                 : String(),
        "WholeScreenshotOrNot"      : false,
        "CaptureRegion"             : [String : Int](),
        "ImagePath"                 : String(),
        "ApplicationInformation"    : [[String : Any]]()
    ]
//    init(TimeStamp : String, WholeScreenshotOrNot : Bool, CaptureRegin : [String : Int], ImagePath : String, ApplicationInformation : [[String : Any]]){
//        self.metaDataSingleRecordingTemplate["TimeStamp"] = TimeStamp
//        self.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = WholeScreenshotOrNot
//        self.metaDataSingleRecordingTemplate["CaptureRegion"] = CaptureRegin
//        self.metaDataSingleRecordingTemplate["ImagePath"] = ImagePath
//        self.metaDataSingleRecordingTemplate["ApplicationInformation"] = ApplicationInformation
//    }
    
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
        "Category"                  : String(),
        "Left"                      : Int(),
        "Top"                       : Int(),
        "Right"                     : Int(),
        "Bottom"                    : Int(),
        "FirstMetaData"             : String(),
        "SecondMetaData"            : String()
    ]
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let jsonFileHandler = jsonFile()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.title = "S"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
        
        
        // create default folder and json file in the Document
        
        let defaultFolderPath = getHomePath() + "/Documents/" + "ScrapbookServer/"
        basicInformation.defaultFolderPathString = defaultFolderPath
        basicInformation.defaultFolderPathURL = URL(string: basicInformation.defaultFolderPathString)
        // print(defaultFolderPath)
        checkDefaultFolder(folderPath: defaultFolderPath)
        
        
        // create json file
        jsonFileHandler.createJson(filepath: basicInformation.defaultFolderPathURL!)
        
        // take a testing screenshot while launching the application for asking request
        takeTestingImage()
        deleteTestingImage()
        
        // Insert code here to initialize your application
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

        arguments.append(basicInformation.defaultFolderPathString + "Testing")
        task.arguments = arguments

        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
         do {
           try task.run()
         } catch {}
        
    }
    
    func deleteTestingImage(){
        let path = basicInformation.defaultFolderPathString  + "Testing"
        do {
          try FileManager.default.removeItem(atPath: path)
        } catch{}
        
    }
    
    // end of the class AppDelegate

}



