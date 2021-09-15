//
//  takeScreenshot.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/30/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation
import AppKit
import Cocoa



extension Collection where Element: Equatable {
    func indexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
extension StringProtocol {
    func indexDistance<S: StringProtocol>(of string: S) -> Int? {
        guard let index = range(of: string)?.lowerBound else { return nil }
        return distance(from: startIndex, to: index)
    }
}


class Screencapture : NSObject {
    
    
    var timerDetectMouseClickAction : Timer = Timer()
    
//    var softeareClassificationHandler = softwareClassify()
//
//    var applescriptHandler = appleScript()
//
    var takeScreenshotSuccess = false
    
    var eventMonitor : EventMonitor?
    
    
    
    var top     = Int()
    var bottom  = Int()
    var left    = Int()
    var right   = Int()
    var width   = Int()
    var height  = Int()
    
    var screenshotCaseIndex = 1
    
    
    // Method of taking screenshot by using terminate command line code
    // /usr/sbin/screencapture
    // -m         only capture the main monitor, undefined if -i is set
    func selectScreenCapture(){
        
        
        var screenshotStruct = screenshotInformation()
        // if degub
        print(screenshotStruct.metaDataSingleRecordingTemplate)
        print(type(of: screenshotStruct))
        
        
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd,HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpg"
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)
        
        screenshotStruct.metaDataSingleRecordingTemplate["TimeStamp"] = dateString
        screenshotStruct.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = false
        let screenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpg"
        screenshotStruct.metaDataSingleRecordingTemplate["ImagePath"] = screenshotPathString
        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = [] as! [[String : Any]]
        print(type(of: screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"]))
        
//        Wednesday, Sep 12, 2018
//        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
//        Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
//        let currentTime = dateFormatter.string(from: date)
//        variables.currentTimeInformation = currentTime
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-s")
        
        let tempScreenshotPath = capturedScreenshotInformation.capturedScreenshotPathString
        arguments.append(tempScreenshotPath)
        
//
//        variables.latesScreenShotPathString = variables.defaultFolderPathString + "Screenshot-" + dateString + ".jpg"
//        variables.latestScreenShotTime = dateString
//        print("save path", variables.latesScreenShotPathString)
        
        
        task.arguments = arguments
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
        

        
        //task.launch() // asynchronous call.
        do {
            try task.run()
                // detect once mouse clicked
                // mouseClick()
            
            
        } catch {
            print("something went wrong")
        }

        // wait until the task is finished
        
        let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        let resultInformation = String(data: outputData, encoding: .utf8)
        
        // output informaion is String format
        let tempScreenshotData = ( resultInformation! )
        // print("output", output!)
        
        print("If debug: before printing mouse location")
        
        var touchPoint = [NSEvent(), mouseLocation] as [Any]
        
        var mouseHandler = NSEvent()
        print(touchPoint)
        
        let mouseXLocation = Int(NSEvent.mouseLocation.x)
        let mouseYLocation = Int(NSEvent.mouseLocation.y)
        print("x & y", mouseXLocation, mouseYLocation)
        
        print ("ScreenshotData", tempScreenshotData)
        
        // get the main screen paramters, width and height
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        let mainScreenHeight = Int(rectArea.size.height)
        let mainScreenWidth = Int(rectArea.size.width)
        
        let mouseEndXLocation = mouseXLocation
        let mouseEndYLocation = mainScreenHeight - mouseYLocation
        
        
        
        
        
        // if it contains "captureRect", successfully captured a screenshot
        // print current mouse location
        
//        var mouseLocation: NSPoint { NSEvent.mouseLocation }
//        NSEvent.addGlobalMonitorForEvents(matching: [.rightMouseDragged, .leftMouseDragged]) { _ in
//            //print(String(format: "%.0f, %.0f", self.mouseLocation().x, self.mouseLocation.y))
//            print("x & y: ")
//            print(mouseLocation.x)
//            print(mouseLocation.y)
//        }
        

        
        if tempScreenshotData.contains("captureRect"){
            
        
            // get the index of ( and )
            // print("first index of (", temp.indexDistance(of: "(")!)
            // print("first index of )", temp.indexDistance(of: ")")!)
            
            // locate the index of "("
            let startPositionInt = tempScreenshotData.indexDistance(of: "(")! + 1
            
            // locate the index of ")"
            let endPositionInt = tempScreenshotData.indexDistance(of: ")")!

            let totalLength = tempScreenshotData.count
            let endPoint = 0 - ( totalLength - endPositionInt )
            
            let startingPoint = tempScreenshotData.index(tempScreenshotData.startIndex, offsetBy: startPositionInt)
            let endingPoint = tempScreenshotData.index(tempScreenshotData.endIndex, offsetBy: endPoint)
            
            let range = startingPoint..<endingPoint
            let recTangleString = tempScreenshotData[range]
            
            print("four coordinations of the current screenshot: ", tempScreenshotData[range])
            
            
            // now I get a string contains coordination of the screenshot
            // get four coordinations: 2874.0, 254.0, 773.0, 580.0
            
            // (12, 12) -> (701, 51) ======= (1452.0, 12.0) -> (701.0, 51.0)
            // 1452 because it is on a additional screen
            
            // hence, these two are the upper left coordination and bottom right coordination
            
            
            // get the first coordination of X
            // get the index of first comma ","
            let firstCommaPosition = recTangleString.indexDistance(of: ",")!
            let firstCommaIndex = recTangleString.index(recTangleString.startIndex, offsetBy: firstCommaPosition)
            let firstCoordinationX = String(recTangleString[..<firstCommaIndex])
            // transfer to Integer value
            var firstCoordinationXInt = (firstCoordinationX as NSString).integerValue
            print("first x: ", firstCoordinationXInt)
            if (firstCoordinationXInt == 0){
                firstCoordinationXInt = 1
            }
            
            
            let secondEndPooint = 0 - (recTangleString.count - firstCommaPosition) + 2
            let secondPartEndIndex = recTangleString.index(recTangleString.endIndex, offsetBy: secondEndPooint)
            // subtract the first coordinate
            let secondPartOfRectangleInformation = recTangleString[secondPartEndIndex...]
            print("second part string: ", secondPartOfRectangleInformation)
            
            // get the first coordination of Y
            let secondCommaPosition = secondPartOfRectangleInformation.indexDistance(of: ",")!
            let secondCommaIndex = secondPartOfRectangleInformation.index(secondPartOfRectangleInformation.startIndex, offsetBy: secondCommaPosition)
            let firstCoordinationY = String(secondPartOfRectangleInformation[..<secondCommaIndex])
            // transfer to Integer value
            var firstCoordinationYInt = (firstCoordinationY as NSString).integerValue
            print("first y: ", firstCoordinationYInt)
            if (firstCoordinationYInt == 0){
                firstCoordinationYInt = 1
            }
            
            
            let thirdEndPoint = 0 - ( secondPartOfRectangleInformation.count - secondCommaPosition ) + 2
            let thirdPartEndIndex = secondPartOfRectangleInformation.index(secondPartOfRectangleInformation.endIndex, offsetBy: thirdEndPoint)
            let thirdPartOfRectangleInformation = secondPartOfRectangleInformation[thirdPartEndIndex...]
            print("third part string: ", thirdPartOfRectangleInformation)
            
            // get the second coordination of X
            let thirdCommaPosition = thirdPartOfRectangleInformation.indexDistance(of: ",")!
            let thirdCommaIndex = thirdPartOfRectangleInformation.index(thirdPartOfRectangleInformation.startIndex, offsetBy: thirdCommaPosition)
            let secondCoordinationX = String(thirdPartOfRectangleInformation[..<thirdCommaIndex])
            var secondCoordinationXInt = (secondCoordinationX as NSString).integerValue
            print("second X: ", secondCoordinationXInt)
            if (secondCoordinationXInt == 0){
                secondCoordinationXInt = 1
            }
            
            
            let forthEndPoint = 0 - ( thirdPartOfRectangleInformation.count - secondCommaPosition) + 2
            let forthPartEndIndex = thirdPartOfRectangleInformation.index(thirdPartOfRectangleInformation.endIndex, offsetBy: forthEndPoint)
            let forthPartOfRectangleInformation = thirdPartOfRectangleInformation[forthPartEndIndex...]
            print("forth part string: ", forthPartOfRectangleInformation)
            
            
//            let forthCommaPosition = forthPartOfRectangleInformation.indexDistance(of: ",")!
//            let forthCommaIndex = forthPartOfRectangleInformation.index(forthPartOfRectangleInformation.startIndex, offsetBy: forthCommaPosition)
//            let secondCoordinationY = String(forthPartOfRectangleInformation[..<forthCommaIndex])
//            var secondCoordinationYInt = (secondCoordinationY as NSString).integerValue
            
            // get the second coordination of Y
            var secondCoordinationYInt = ( forthPartOfRectangleInformation as NSString).integerValue
            print("second Y: ", secondCoordinationYInt)
            if (secondCoordinationYInt == 0){
                secondCoordinationYInt = 1
            }

            
            // upper left coordination(firstCoordinationXInt, firstCoordinationYInt)
            // bottom right coordination(secondCoordinationXInt, secondCoordinationYInt)
            // the width of the screenshot is
            print("four points")
            print(firstCoordinationXInt) // width, which is x
            print(firstCoordinationYInt) // height, which is y
            print(secondCoordinationXInt) // screenshot width
            print(secondCoordinationYInt)   // screenshot height
            
            let screenshotUpperLeftX = firstCoordinationXInt
            let screenshotUpperLeftY = firstCoordinationYInt
            let screenshotWidthInRect = secondCoordinationXInt
            let screenshotHeightInRect = secondCoordinationYInt
            
            // four cases:
            // 1: upper left -> bottom right
            // 2: bottom left -> upper right
            // 3: upper right -> bottom left
            // 4: bottom right -> upper left
            let mouseStartXLocation = firstCoordinationXInt
            let mouseStartYLocation = firstCoordinationYInt
            
            // default case is 0, can be used as indicating a failure of taking screenshot
            // corner case check
            
//            if (mouseStartXLocation == mouseEndXLocation || mouseEndYLocation == mouseStartXLocation){
//                screenshotCaseIndex = 0
//            }
            
            if(screenshotHeightInRect == 0 || screenshotWidthInRect == 0){
                screenshotCaseIndex = 0
            }
            // 1 -------2
            // |        |
            // 3 -------4
            
//            // case 1:
//            if (mouseEndXLocation > mouseStartXLocation && mouseEndYLocation > mouseStartYLocation){
//                screenshotCaseIndex = 1
//            }
//            // case 2
//            else if (mouseEndXLocation < mouseStartXLocation && mouseEndYLocation > mouseStartXLocation){
//                screenshotCaseIndex = 2
//            }
//            else if(mouseEndXLocation > mouseStartXLocation && mouseEndYLocation < mouseStartYLocation){
//                screenshotCaseIndex = 3
//            }
//            else if(mouseEndXLocation < mouseStartXLocation && mouseEndYLocation < mouseStartYLocation){
//                screenshotCaseIndex = 4
//            }
//                // code here
//            else {
//
//            }
            
            secondCoordinationXInt = mouseEndXLocation
            secondCoordinationYInt = mouseEndYLocation
            
//            screenShotInformation.firstCoordinationOfX = firstCoordinationXInt
//            screenShotInformation.firstCoordinationOfY = firstCoordinationYInt
//            screenShotInformation.secondCoordinationOfX = firstCoordinationXInt + secondCoordinationXInt
//            screenShotInformation.secondCoordinationOfY = firstCoordinationYInt + secondCoordinationYInt
            
//            alternativeUserInterfaceVariables.capturedApplicationCount = 0
//            alternativeUserInterfaceVariables.capturedApplicationNumber = 0
            
            
            // takeScreenshotSuccess = true
            
            let tempWidthValue = calculateWidth(valueOne: firstCoordinationXInt, valueTwo: secondCoordinationXInt)
            let tempHeightValue = calculateHeight(valueOne: firstCoordinationYInt, valueTwo: secondCoordinationYInt)
            
            
            
            // 1 -------2
            // |        |
            // 3 -------4
//            if (screenshotCaseIndex == 1){
//                top     = mouseStartYLocation
//                bottom  = mouseEndYLocation
//                left    = mouseStartXLocation
//                right = mouseEndXLocation
//            }
//            // bug code here
//            else if (screenshotCaseIndex == 2){
//                top     = mouseStartYLocation
//                bottom  = mouseEndYLocation
//                left    = mouseEndXLocation
//                right   = mouseStartXLocation
//            }
//            else if (screenshotCaseIndex == 3){
//                top     = mouseEndYLocation
//                bottom  = mouseStartYLocation
//                left    = mouseEndXLocation
//                right   = mouseStartXLocation
//            }
//            else if (screenshotCaseIndex == 4){
//                top     = mouseEndYLocation
//                bottom  = mouseStartYLocation
//                left    = mouseEndXLocation
//                right   = mouseStartXLocation
//            }
            
            width = tempWidthValue
            height = tempHeightValue
            
            
            /*
             ignore previous screenshotCaseIndex, expcet 0
             
             */
            
            top = Int(screenshotUpperLeftY)
            bottom = Int(screenshotUpperLeftY) + Int(screenshotHeightInRect)
            left = Int(screenshotUpperLeftX)
            right = Int(screenshotUpperLeftX) + Int(screenshotWidthInRect)
            width = Int(screenshotWidthInRect)
            height = Int(screenshotHeightInRect)
            
            
            print(top) // width, which is x
            print(bottom) // height, which is y
            print(left) // screenshot width
            print(right)   // screenshot height
            
            
        }
        
        if (screenshotCaseIndex == 0){
            takeScreenshotSuccess = false
            print("the captured screenshot is not valid")
            // end this function
            return
        }
        else {
            takeScreenshotSuccess = true
        }
        
        // assgin values into screenshot region struct
        let currentScreenshotReginInfor = screenshotCaptureRegion(left: left, top : top, right : right, bottom : bottom, width : width, height : height)
        
        // 
        screenshotStruct.metaDataSingleRecordingTemplate["CaptureRegion"] = currentScreenshotReginInfor
        

        // wait until all tasks finished, including saving pic, etc
        task.waitUntilExit()
        
        if (takeScreenshotSuccess){
            
            // get captured application names
            print("screenshot informaiont:")
            print(currentScreenshotReginInfor)
            print(type(of: currentScreenshotReginInfor))
            
            let applicationNameStackHandler = softwareClassify()
            
            
            
            // from old algorithm
            // let visiableApplicationNameArray = applicationNameStackHandler.getOpenedRunningApplicaionNameList(imageInfor: currentScreenshotReginInfor, wholeInfor : &screenshotStruct)
            
            // from bit masking algorithm
            let visiableApplicationNameArrayFromBitMasking = applicationNameStackHandler.getOpenedRunningApplicaionNameListWithBitMasking(imageInfor: currentScreenshotReginInfor, wholeInfor: &screenshotStruct)
            
            
            print(visiableApplicationNameArrayFromBitMasking)
            print("screenshot informaiton is: ")
            print(screenshotStruct)
            
            
            
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
            
            
            let capturedApplicationInformationDic = screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
            
            // two for loops to search application name and get metdata
            for singleAppInfor in capturedApplicationInformationDic{
                
                let appName = singleAppInfor["ApplicationName"]
                for i in 0..<csvContentRow{
                }
                
            }
            
            
            
            
            // applicationNameStack.test(data: currentScreenshotReginInfor)
            // let applicationNameStack = softwareClassify.getOpenedRunningApplicaionNameList(data: currentScreenshotReginInfor)

            
            // let applicationNameStack = softeareClassificationHandler.screenAboveWindowListPrint()
            // let applicationNameStackLength = applicationNameStack.count
            
            // applescriptHandler.applicationMetaData(applicationNameStack: applicationNameStack)
            print("the process of takeing screenshot is finished, and the images has been saved locally.")
           
                 
            // open the "captured view"
//            let temp2 : NSViewController = testViewController()
//            let subWindow2 = NSWindow(contentViewController: temp2)
//            let subWindowController2 = NSWindowController(window: subWindow2)
//            subWindowController2.showWindow(nil)
            
//            let temp3: NSViewController = testViewController()
//            temp3.view.display()
            
            
            
        }
            
            
        else {
            print("the action of taking a screenshot failed. please repeat your action.")
        }
        
        
    }


    @objc func mouseClick(){
        
        let bool = NSEvent.pressedMouseButtons
        if bool == 1 {
            let xMouseCoordination = NSEvent.mouseLocation.x
            let yMouseCoordination = NSEvent.mouseLocation.y
                        
            print("mouse location of starting: ", xMouseCoordination, yMouseCoordination)
        }
    }
    
    func mouseLocation(){
        let xMouseCoordination = NSEvent.mouseLocation.x
        let yMouseCoordination = NSEvent.mouseLocation.y
        print("mouse locatin of ending: ", xMouseCoordination, yMouseCoordination)
    }
    
    // calculate the width of the screenshot
    func calculateWidth(valueOne : Int, valueTwo : Int) -> Int{
        if (valueOne >= valueTwo) {
            return valueOne - valueTwo
        }
        else {
            return valueTwo - valueOne
        }
    }
    
    // calculate the height of the screenshot
    func calculateHeight(valueOne : Int, valueTwo : Int) -> Int {
        if (valueOne >= valueTwo) {
            return valueOne - valueTwo
        }
        else {
            return valueTwo - valueOne
        }
    }
    
    

    
    // taks screenshot for the whole screen, still need revise
    func wholeScreenCapture(){

        // let secondsToDelay = 5.0

        do {
            sleep(UInt32(0.8))
        }


        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd,HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpg"
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)

        //dateFormatter.dateFormat = "yyyy, MMMM, dd, E, hh:mm:ss"
    //        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy"
    //        let currentTime = dateFormatter.string(from: date)
    //        variables.currentTimeInformation = currentTime
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        // do not play sound
        arguments.append("-x")
        
        let tempScreenshotPath = capturedScreenshotInformation.capturedScreenshotPathString
        arguments.append(tempScreenshotPath)
        

        task.arguments = arguments
        let outpipe = Pipe()
        task.standardOutput = outpipe
        task.standardError = outpipe
        // wait a second to wait the menu window disappear
        do {
          try task.run()
        } catch {}
        //task.launch() // asynchronous call.
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outdata, encoding: .utf8)
        let tempScreenshotData = ( output! )
        // print("output", output!)
        
        // get the main screen paramters, width and height
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        
        // check here again, -1 or not
        
        let mainScreenHeight = rectArea.size.height
        let mainScreenWidth = rectArea.size.width
        

        let firstCoordinationOfX = 0
        let firstCoordinationOfY = 0
        let secondCoordinationOfX = Int(mainScreenWidth)
        let secondCoordinationOfY = Int(mainScreenHeight)
        
        

        task.waitUntilExit()
        // screenshot capturing is successed
        takeScreenshotSuccess = true

        
        if (takeScreenshotSuccess){
            
//            let applicationNameStack = softeareClassificationHandler.screenAboveWindowListPrint()
//            // let applicationNameStackLength = applicationNameStack.count
//            applescriptHandler.applicationMetaData(applicationNameStack: applicationNameStack)
            
            print("the process of takeing screenshot is finished, and the images has been saved locally.")
            // let applicationNameStack = softwareClassify.getOpenedRunningApplicaionNameList()
            
//            let temp2 : NSViewController = testViewController()
//            let subWindow2 = NSWindow(contentViewController: temp2)
//            let subWindowController2 = NSWindowController(window: subWindow2)
//            subWindowController2.showWindow(nil)
        }

        else {
            print("the action of taking a screenshot failed. please repeat your action.")
            }

        }
    
    // end of class
    
}

