//
//  croppingImage.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 3/10/22.
//  Copyright © 2022 Donghan Hu. All rights reserved.
//

import Cocoa
import AppKit
import QuartzCore

class croppingImage: NSViewController, NSWindowDelegate {

    @IBOutlet weak var displayImage: NSImageView!
    @IBOutlet weak var instructionLabel: NSTextField!
    
    lazy var window: NSWindow = self.view.window!
    var mouseLocation: NSPoint { NSEvent.mouseLocation }
    var location: NSPoint { window.mouseLocationOutsideOfEventStream }
    
    var monitorLeftMouseDown: Any?
    var monitorLeftMouseUp: Any?
    var monitorDrag: Any?
    
    var takeScreenshotSuccess = true
    var screenshotCaseIndex = 1
    
    var numberToOrdinalDictionary = [
        1 : "first",
        2 : "second",
        3 : "third",
        4 : "fourth",
        5 : "fifth",
        6 : "sixth",
        7 : "seventh",
        8 : "eighth",
        9 : "ninth",
        10 : "tenth"
    ]
    
    var openSafariScript =
    """
    tell application "Safari"
        activate
        tell window 1
            open location "http://localhost:8080/capturedView.html"
            set bounds to {100, 30, 1400, 850}
        end tell
    end tell
    """
    
    override func viewWillAppear() {
        super.viewWillAppear()
        window.acceptsMouseMovedEvents = true
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    func windowWillClose(_ notification: Notification) {
        print("window closed")
        if let monitorLeftMouseDown = monitorLeftMouseDown {
            NSEvent.removeMonitor(monitorLeftMouseDown)
        }
        if let monitorLeftMouseUp = monitorLeftMouseUp {
            NSEvent.removeMonitor(monitorLeftMouseUp)
        }
    }
    
    class disImage: NSImageView {
        override func resetCursorRects() {
            super.resetCursorRects()
            addCursorRect(bounds, cursor: .crosshair)
        }

        //MARK:Properties
        var startPoint : NSPoint!
        var shapeLayer : CAShapeLayer!
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)

            // Drawing code here.
        }
        override func mouseDown(with event: NSEvent) {

            self.startPoint = self.convert(event.locationInWindow, from: nil)

            shapeLayer = CAShapeLayer()
            shapeLayer.lineWidth = 1.0
            shapeLayer.fillColor = NSColor.clear.cgColor
            shapeLayer.strokeColor = NSColor.black.cgColor
            shapeLayer.lineDashPattern = [10,5]
            self.layer?.addSublayer(shapeLayer)

            var dashAnimation = CABasicAnimation()
            dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.duration = 0.75
            dashAnimation.fromValue = 0.0
            dashAnimation.toValue = 15.0
            dashAnimation.repeatCount = .infinity
            shapeLayer.add(dashAnimation, forKey: "linePhase")

        }

        override func mouseDragged(with event: NSEvent) {

            let point : NSPoint = self.convert(event.locationInWindow, from: nil)
            let path = CGMutablePath()
            path.move(to: self.startPoint)
            path.addLine(to: NSPoint(x: self.startPoint.x, y: point.y))
            path.addLine(to: point)
            path.addLine(to: NSPoint(x:point.x,y:self.startPoint.y))
            path.closeSubpath()
            self.shapeLayer.path = path
        }

        override func mouseUp(with event: NSEvent) {
            self.shapeLayer.removeFromSuperlayer()
            self.shapeLayer = nil
        }
    }
    
    var initStartX: CGFloat?
    var initStartY: CGFloat?
    var initEndX: CGFloat?
    var initEndY: CGFloat?
    
    var windowWidth: CGFloat?
    var windowHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.title = "Crop screenshot"
        instructionLabel.stringValue = "Please click this text area first. When the cursor changes to a crossline, you can start dragging to select area in this screenshot."
        
        let editImageView = disImage(frame: CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 60))
        view.addSubview(editImageView)
        
        self.view.window?.level = NSWindow.Level.floating
        
        displayImage.imageScaling = .scaleProportionallyUpOrDown
        let fileManager = FileManager.default
        
        let screenshotPathString = tempCropScreenshotPath
        if fileManager.fileExists(atPath: screenshotPathString){
            print("imgae existed")
        }
        else {
            print("image not existed")
        }
        
        let currentScreenshot = NSImage(contentsOfFile: screenshotPathString)
        displayImage.image = currentScreenshot
        
        
        // get the main screen paramters, width and height
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        let mainScreenHeight = Int(rectArea.size.height)
        let mainScreenWidth = Int(rectArea.size.width)
        print("screenwidth is: ", mainScreenWidth)
        print("screenheigth is: ", mainScreenHeight)
        
        // get window width and height
        windowWidth = self.view.frame.size.width - 20
        windowHeight = self.view.frame.size.height - 60
        print("window width is: ", self.view.frame.size.width)
        print("window height is: ", self.view.frame.size.height)
        
        monitorLeftMouseDown = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) {
            // print("leftmouse down, mouseLocation:", String(format: "%.1f, %.1f", self.mouseLocation.x, self.mouseLocation.y))
            print("leftmouse down, windowLocation:", String(format: "%.1f, %.1f", self.location.x - 10, self.location.y - 10))
            
            self.initStartX = self.location.x - 10
            self.initStartY = self.location.y - 10

            return $0
        }
        
        monitorLeftMouseUp = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) {
            // print("leftmouse up, mouseLocation:", String(format: "%.1f, %.1f", self.mouseLocation.x, self.mouseLocation.y))
            print("leftmouse up, windowLocation:", String(format: "%.1f, %.1f", self.location.x - 10, self.location.y - 10))
            self.initEndX = self.location.x - 10
            self.initEndY = self.location.y - 10
            var tempx : CGFloat = self.location.x
            var tempy : CGFloat = self.location.y
            // start point should not be above the top frame line
            // end point should not be above top frame line 20.
            if(Int(self.initStartY!) > Int(self.windowHeight! - 50) || tempx > self.windowWidth! || tempy > self.windowHeight! - 30){
                print("invalide click")
            }else{
                // remove mouse event listener
                if let monitorLeftMouseDown = self.monitorLeftMouseDown {
                    NSEvent.removeMonitor(monitorLeftMouseDown)
                }
                if let monitorLeftMouseUp = self.monitorLeftMouseUp {
                    NSEvent.removeMonitor(monitorLeftMouseUp)
                }
                let tempImage = self.getTempCropImage()
                let secondsToDelay = 0.5
                var answer : Bool?
                DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                    print("This message is delayed")
                    answer = self.confirmAbletonIsReady(question: "Please check is this your target screenshot?", text: "Click \"Cancel\" to reselct screenshot area. Click \"Confirm\" to review detials.")
                    print("answer is: ", answer)
                    if(answer == true){
                        
                        self.saveCroppedImage(result: tempImage)
                        self.view.window?.close()
                        self.getMetadata()
                    }else{
                        print("click cancel button")
                        self.viewDidLoad()
                    }
                    
                }
            }
            return $0
        }
    }
    
    func getMetadata(){
        
        var simpleWholeInfor = ""
        var screenshotStruct = screenshotInformation()
        screenshotStruct.metaDataSingleRecordingTemplate["TimeStamp"] = fromCropScreenshot.timeStamp
        screenshotStruct.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = false
        // let screenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        screenshotStruct.metaDataSingleRecordingTemplate["ImagePath"] = fromCropScreenshot.imagePath
        screenshotStruct.metaDataSingleRecordingTemplate["ScreenshotPictureName"] = fromCropScreenshot.screenshotFileName
        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = [] as! [[String : Any]]
        
        let left = fromCropScreenshot.leftValue
        let right = fromCropScreenshot.rightValue
        let top = fromCropScreenshot.topValue
        let bottom = fromCropScreenshot.bottomValue
        let width = fromCropScreenshot.widthValue
        let height = fromCropScreenshot.heightValue
        
        // assgin values into screenshot region struct
        let currentScreenshotReginInfor = screenshotCaptureRegion(left: left, top : top, right : right, bottom : bottom, width : width, height : height)
        screenshotStruct.metaDataSingleRecordingTemplate["CaptureRegion"] = currentScreenshotReginInfor.screenshotRegion as! [String : Int]
        // get captured application names
        let applicationNameStackHandler = softwareClassify()
        // from bit masking algorithm
        // code here
        
        let visiableApplicationNameArrayFromBitMasking = applicationNameStackHandler.getOpenedRunningApplicaionNameListWithBitMasking(imageInfor: currentScreenshotReginInfor, wholeInfor: &screenshotStruct)
        
        // put captured application names into an array and saved as a global variable for future use
        tempScreenshotInformationStruct.capturedApplicationNameArray = visiableApplicationNameArrayFromBitMasking
        print("tempScreenshotInformationStruct.capturedApplicationNameArray",tempScreenshotInformationStruct.capturedApplicationNameArray)
        // get metadata for each application saved in this struct
        let csvFilesOperationsHandler = csvFilesOperations()
        let csvContent = csvFilesOperationsHandler.readCSVFile(filePath: "AppleScripts")
        // csvContentRow: the number of default application
        let csvContentRow = csvContent.count
        // csvContentCol:
        // [0] : application name
        // [1] : application category
        // [2] : metadata 1
        // [3] : metadata 2
        let csvContentCol = csvContent[0].count
        // Array<Array<String>>
        var capturedApplicationInformationDic = screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
        print(capturedApplicationInformationDic)
        print(capturedApplicationInformationDic.count)
        // dictiornary for repeating application names
        // e.g., two google chrome
        var dictionaryForRepeatApplicationNames = [String : Int]()
        
        // two for loops to search application name and get metdata
        for (appIndex, singleAppInfor) in capturedApplicationInformationDic.enumerated(){
            let appName = singleAppInfor["ApplicationName"] as! String
            // update dictionaryForRepeatApplicationNames
            // first time meet this application name
            if (dictionaryForRepeatApplicationNames[appName] == nil){
                dictionaryForRepeatApplicationNames[appName] = 1;
            }
            // previously, seen this application name
            else{
                let previousValue = dictionaryForRepeatApplicationNames[appName]
                // upadate
                dictionaryForRepeatApplicationNames[appName] = previousValue! + 1
            }
            var foundOrNot = false;
            for i in 0..<csvContentRow{
                let eachRowInArray = csvContent[i] as Array<String>
                let tempApplicationName = eachRowInArray[0] as String
                if (tempApplicationName == appName){
                    foundOrNot = true
                    // get the time that this application has appeared
                    let seenCount = dictionaryForRepeatApplicationNames[appName]
                    let categoryIndex = eachRowInArray[1] as String
                    var appleScriptForMetaDataOne = eachRowInArray[2] as String
                    var appleScriptForMetaDataTwo = eachRowInArray[3] as String
                    appleScriptForMetaDataOne = getExecutableAppleScriptByReplacingName(originalString: appleScriptForMetaDataOne, applicationName: appName)
                    appleScriptForMetaDataTwo = getExecutableAppleScriptByReplacingName(originalString: appleScriptForMetaDataTwo, applicationName: appName)
                    // default value is 1
                    let rankValue = numberToOrdinalDictionary[seenCount ?? 1]
                    // method one (current): if applescript contains "AlternativeRankNumber"
                    // method two: check application name to determine repleace or not
                    if(appleScriptForMetaDataOne.contains("AlternativeRankNumber")){
                        appleScriptForMetaDataOne = getExecutableAppleScriptByReplacingRank(originalString: appleScriptForMetaDataOne, rank: rankValue ?? "first")
                    }
                    if (appleScriptForMetaDataTwo.contains("AlternativeRankNumber")){
                        appleScriptForMetaDataTwo = getExecutableAppleScriptByReplacingRank(originalString: appleScriptForMetaDataTwo, rank: rankValue ?? "first")
                    }
                    print("two apple scripts after replacing name and rank values are below: ")
                    print("appscript one:", appleScriptForMetaDataOne)
                    print("appscript two:", appleScriptForMetaDataTwo)
                    let applicationMetadataResultOne = runApplescript(applescript: appleScriptForMetaDataOne)
                    let applicationMetadataResultTwo = runApplescript(applescript: appleScriptForMetaDataTwo)
                    print("result one:", applicationMetadataResultOne)
                    print("result two:", applicationMetadataResultTwo)
                    var appDictTemp = capturedApplicationInformationDic[appIndex]
                    print("appIndex:", appIndex)
                    appDictTemp["Category"] = categoryIndex
                    appDictTemp["FirstMetaData"] = applicationMetadataResultOne
                    appDictTemp["SecondMetaData"] = applicationMetadataResultTwo
                    appDictTemp["Rank"] = rankValue
                    appDictTemp["ApplicationNameWithRank"] = appName + "(" + String(describing: seenCount) + ")"
                    print("appDictTemp:", appDictTemp)
                    capturedApplicationInformationDic[appIndex] = appDictTemp
                // end of if statement (tempApplicationName == appName)
                }
            // end of for loop for i in 0..<csvContentRow
            }
            // this applicaiton is not saved in the csv file, then use default string for metadata
            if (foundOrNot == false){
                let seenCount = dictionaryForRepeatApplicationNames[appName]
                let rankValue = numberToOrdinalDictionary[seenCount ?? 1]
                var appDictTemp = capturedApplicationInformationDic[appIndex]
                appDictTemp["Category"] = "Undefined"
                appDictTemp["FirstMetaData"] = "Sorry, metadata for this software is not available!"
                appDictTemp["SecondMetaData"] = "Sorry, metadata for this software is not available!"
                appDictTemp["Rank"] = rankValue
                capturedApplicationInformationDic[appIndex] = appDictTemp
            }
                
        // end of for loop for singleAppInfor in capturedApplicationInformationDic
        }
        // write new data struct into screenshotStruct
        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = capturedApplicationInformationDic
        print("after adding metadata, the final screenshotStruct")
        print(screenshotStruct)
        // simpleWholeInfor
        let elementCount = capturedApplicationInformationDic.count
        print(simpleWholeInfor)
        let allValuesInString = capturedApplicationInformationDic.description
        print(allValuesInString)
        // code here, adding new string value
        screenshotStruct.metaDataSingleRecordingTemplate["AppInforString"] = simpleWholeInfor
        print("the process of takeing screenshot is finished, and the images has been saved locally.")
        tempScreenshotInformationStruct.dataDictionary = screenshotStruct.metaDataSingleRecordingTemplate
        print(tempScreenshotInformationStruct.dataDictionary)
        
        // code here, 3/11
        print("visiable application name stack is: ")
        print(visiableApplicationsNameArrayPublic)
        // tempScreenshotInformationStruct.dataDictionary or screenshotStruct.metaDataSingleRecordingTemplate
        var originalData = tempScreenshotInformationStruct.dataDictionary
        var invisiableAppNamesArray = [String]()
        var originalAppInfor = originalData["ApplicationInformation"] as! [[String : Any]]
        
        // originalData["ApplicationInformation"]
        for (index, item) in originalAppInfor.enumerated() {
            let currentAppName = item["ApplicationName"] as! String
            // if this appname is not in the visableAppName's list
            if(!visiableApplicationsNameArrayPublic.contains(currentAppName)){
                invisiableAppNamesArray.append(currentAppName)
            }
            // print("Found \(item) at position \(index)")
        }
        
        for (index, item) in (visiableApplicationsNameArrayPublic).enumerated().reversed() {
            if(item.contains("pid")){
                visiableApplicationsNameArrayPublic.remove(at: index)
            }
        }
        
        for (index, item) in (invisiableAppNamesArray).enumerated().reversed() {
             if(item.contains("pid")){
                 invisiableAppNamesArray.remove(at: index)
             }
         }
        
        originalData["VisiableApplicationNames"] = visiableApplicationsNameArrayPublic
        originalData["InvisiableApplicationNames"] = invisiableAppNamesArray
        
        for(index, item) in originalAppInfor.enumerated().reversed() {
            let appNameString = item["ApplicationName"] as! String
            if (appNameString.contains("pid=")){
                originalAppInfor.remove(at: index)
            }
        }
        
        print("previous data stuct is: ")
        print(tempScreenshotInformationStruct.dataDictionary)
        
        print("after revising, the data struct is: ")
        originalData["ApplicationInformation"] = originalAppInfor
        print(originalData)
        // originalData is the final one
        
        
        // save this temp screenshot's informatino to the temp json file
        // tempScreenshotInformationStruct.dataDictionary
        let tempJsonFileHandler = tempJsonFileOperations();
        // clear the temp json file first
        tempJsonFileHandler.clearTempJsonFile(FilePath: basicInformation.tempScreenshotJsonFilePathString)
        // overwrite new temp json data into the file
        // replace the old one with invisiableStruct
        // tempJsonFileHandler.writeTempJsonData(screenshotDic: tempScreenshotInformationStruct.dataDictionary)
        tempJsonFileHandler.writeTempJsonData(screenshotDic: originalData)
        
        if (takeScreenshotSuccess == true){
            // open in the browser
             runApplescript(applescript: openSafariScript)
        }
        else{
            // takeScreenshotSuccess is false
        }
        
        // end of the getMetadata()
    }
    
    func getTempCropImage() -> NSImage{
        let startPointX = min(initStartX!, initEndX!)
        let startPointY = max(initStartY!, initEndY!)
        let endPointX = max(initStartX!, initEndX!)
        let endPointY = min(initStartY!, initEndY!)
        
        
        let left = min(initStartX!, initEndX!)
        let top = max(initStartY!, initEndY!)
        let right = max(initStartX!, initEndX!)
        let bottom = min(initStartY!, initEndY!)
        let width = abs(initEndX! - initStartX!)
        let height = abs(initEndY! - initStartY!)
        
        let screenshotPathString = tempCropScreenshotPath
        let originalImage = NSImage(contentsOfFile: screenshotPathString)
        
        let imageViewScale = max(originalImage!.size.width / displayImage.frame.size.width,
                                 originalImage!.size.height / displayImage.frame.size.height)
        print("imageViewScale is: ", imageViewScale)
        
        
        let sourceSize = originalImage!.size
        print("image in source width: ", sourceSize.width)
        print("image in source height: ", sourceSize.height)
        print("image in window width: ", windowWidth!)
        print("image in window height: ", windowHeight!)
        
        // coordinates in NSView
        print("left", left)
        print("right", right)
        print("top", top)
        print("bottom", bottom)
        print("width", width)
        print("height", height)
        // CGFloat
        
        let screenHeight = sourceSize.height
        let screenWidth = sourceSize.width
        print("original image width: ", sourceSize.width)
        print("original image height: ", sourceSize.height)
        // equals to screen's height and width
        
        // 960 should be replaced with window width, same as 600
        let newWidth = sourceSize.width * width / windowWidth!
        let newHeight = sourceSize.height * height / windowHeight!
        print("width in imageView is: ", newWidth)
        print("height in imageView is: ", newHeight)
        
        // bottom left point
        let newXOffset = sourceSize.width * left / windowWidth!
        let newYOffset = sourceSize.height * bottom / windowHeight!
        
        let newTop = sourceSize.height * top / windowHeight!
        print("new offset of top: ", newTop)
        
        print("new offset x: ", newXOffset)
        print("new offset y: ", newYOffset)
        
        let xOffset = newXOffset
        let yOffset = newYOffset
        
        let originalLeft = sourceSize.width * left / windowWidth!
        let originalRight = sourceSize.width * right / windowWidth!
        let originalTop = sourceSize.height * top / windowHeight!
        let originalBottom = sourceSize.height * bottom / windowHeight!
        var originalWidth = Int(originalRight) - Int(originalLeft)
        if(originalWidth < 0){
            originalWidth = 0
        }
        var originalHeight = Int(originalTop) - Int(originalBottom)
        if(originalHeight < 0){
            originalHeight = 0
        }
        
        // top is smaller than bottom
        let transferredTop = Int(screenHeight) - Int(originalTop)
        let transferredBottom = transferredTop + originalWidth
        
        fromCropScreenshot.leftValue = Int(originalLeft)
        fromCropScreenshot.rightValue = Int(originalRight)
        fromCropScreenshot.topValue = transferredTop
        fromCropScreenshot.bottomValue = transferredBottom
        //fromCropScreenshot.topValue = Int(originalTop)
        //fromCropScreenshot.bottomValue = Int(originalBottom)
        fromCropScreenshot.widthValue = originalWidth
        fromCropScreenshot.heightValue = originalHeight
        
        print("original left: ", originalLeft)
        print("original right: ", originalRight)
        print("original top: ", transferredTop)
        print("original bottom: ", transferredBottom)
        print("original width: ", originalWidth)
        print("original height: ", originalHeight)
        
        
        
        // The cropRect is the rect of the image to keep,
        // in this case centered
        // top left point
        let cropRect = CGRect(
            x: CGFloat(xOffset),
            y: CGFloat(yOffset),
            width: CGFloat(newWidth),
            height: CGFloat(newHeight)
        ).integral
        
        let result = NSImage(size: cropRect.size)
        result.lockFocus()
        let destRect = CGRect(origin: .zero, size: result.size)
        originalImage!.draw(in: destRect, from: cropRect, operation: .copy, fraction: 1.0)
        result.unlockFocus()
        displayImage.image = result
        return result
    }
    
    func saveCroppedImage(result : NSImage){
        let filePath = "file://\(tempCropScreenshotPath)"
        let newScreenshotUrl = URL(string: filePath)
        print("screenshot url: ", newScreenshotUrl)
        let picture = result

        let imageURL = newScreenshotUrl!
        if let png = picture.jpeg {
            do {
                try png.write(to: imageURL)
                print("new jpeg image saved")
            } catch {
                print(error)
            }
        }
    }
    
    func confirmAbletonIsReady(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Confirm")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
            
    func runApplescript(applescript : String) -> String{
        let tempStr = String(applescript)
        let validString = tempStr.replacingOccurrences(of: "\\n", with: "\n")
        print("validString", validString)
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
    func getExecutableAppleScriptByReplacingName(originalString: String, applicationName : String) -> String{
        let tempString = originalString
        let executabltAppleScript = tempString.replacingOccurrences(of: "AlternativeApplicationName", with: applicationName)
        return executabltAppleScript
    }
    
    
    func getExecutableAppleScriptByReplacingRank(originalString : String, rank : String) -> String {
        let executableAppleScript = originalString.replacingOccurrences(of: "AlternativeRankNumber", with: rank)
        return executableAppleScript
    }
    
    
    // end of the class
}

extension NSBitmapImageRep {
    var jpeg: Data? { representation(using: .jpeg, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var jpeg: Data? { tiffRepresentation?.bitmap?.jpeg }
}
