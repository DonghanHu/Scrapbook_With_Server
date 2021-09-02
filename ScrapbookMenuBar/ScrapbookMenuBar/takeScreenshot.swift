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
    
    
    
    
    
    // Method of taking screenshot by using terminate command line code
    // /usr/sbin/screencapture
    // -m         only capture the main monitor, undefined if -i is set
    func selectScreenCapture(){
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd,HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpg"
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)
        
        
        
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
            try
                //
                
                task.run()
            
                // detect once mouse clicked
                // mouseClick()
            
            
        } catch {}

        // wait until the task is finished
        
        
        let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        let resultInformation = String(data: outputData, encoding: .utf8)
        
        // output informaion is String format
        let tempScreenshotData = ( resultInformation! )
        // print("output", output!)
        print ("ScreenshotData", tempScreenshotData)
        
        
        // if it contains "captureRect", successfully captured a screenshot
        // print current mouse location
        

        
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
            
            secondCoordinationXInt = secondCoordinationXInt + firstCoordinationXInt
            secondCoordinationYInt = firstCoordinationYInt + secondCoordinationYInt
            print(secondCoordinationXInt)
            print(secondCoordinationYInt)
            
//            screenShotInformation.firstCoordinationOfX = firstCoordinationXInt
//            screenShotInformation.firstCoordinationOfY = firstCoordinationYInt
//            screenShotInformation.secondCoordinationOfX = firstCoordinationXInt + secondCoordinationXInt
//            screenShotInformation.secondCoordinationOfY = firstCoordinationYInt + secondCoordinationYInt
            
//            alternativeUserInterfaceVariables.capturedApplicationCount = 0
//            alternativeUserInterfaceVariables.capturedApplicationNumber = 0
            
            
            // takeScreenshotSuccess = true
            
            let width = calculateWidth(valueOne: firstCoordinationXInt, valueTwo: secondCoordinationXInt)
            let height = calculateHeight(valueOne: firstCoordinationYInt, valueTwo: secondCoordinationYInt)
            
            // top, left, bottom, right
            // need revision here
            let top = min(firstCoordinationYInt, secondCoordinationYInt)
            let bottom = max(firstCoordinationYInt, secondCoordinationYInt)
            let left = min(firstCoordinationXInt, secondCoordinationXInt)
            let right = max(firstCoordinationXInt, secondCoordinationXInt)
            
            
            print(top)
            print(bottom)
            print(left)
            print(right)
            
//            var wholeImageInfor = [String]()
//            wholeImageInfor.append("whole")
//            let stringX = String(firstCoordinationXInt)
//            let stringY = String(firstCoordinationYInt)
//            let stringWidth = String(width)
//            let stringHeight = String(height)
//            wholeImageInfor.append(stringX)
//            wholeImageInfor.append(stringY)
//            wholeImageInfor.append(stringWidth)
//            wholeImageInfor.append(stringHeight)
//            var tempdic = ["whole": wholeImageInfor] as NSDictionary

            
            let currentScreenshotReginInfor = screenshotCaptureRegion(left: firstCoordinationXInt, top: firstCoordinationYInt, width: width, height: height)
            
            
            
            // capturedApplicationsCoordinates.caputredCoordinates.merge(dict: tempdic as! [String : [String]])
            // print("the captured whole image informaiton", capturedApplicationsCoordinates.caputredCoordinates)
            
        }
        
        
        takeScreenshotSuccess = true
        task.waitUntilExit()
        
        if (takeScreenshotSuccess){
            
            // let applicationNameStack = softeareClassificationHandler.screenAboveWindowListPrint()
            // let applicationNameStackLength = applicationNameStack.count
            // applescriptHandler.applicationMetaData(applicationNameStack: applicationNameStack)
            print("the process of takeing screenshot is finished, and the images has been saved locally.")
           
                 
            
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
        
        
        
        
        // print("output", output1)
        
        // mouseLocation()
        
        
        // softeareClassifyHandler.frontmostApplication()
        
        // timerDetectMouseClickAction.invalidate()
//        print("timer detecting mouse action has been stopped.")
        
        //pause for 0.5 second
        //sleep(UInt32(0.5))
        


        
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
        let mainScreenHeight = rectArea.size.height
        let mainScreenWidth = rectArea.size.width
        
//        print("height", height)
//        print("width", width)

//        screenShotInformation.firstCoordinationOfX = 0
//        screenShotInformation.firstCoordinationOfY = 0
//        screenShotInformation.secondCoordinationOfX = Int(width)
//        screenShotInformation.secondCoordinationOfY = Int(height)
//        alternativeUserInterfaceVariables.capturedApplicationCount = 0
//        alternativeUserInterfaceVariables.capturedApplicationNumber = 0
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
