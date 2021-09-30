//
//  softwareClassification.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/31/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class softwareClassify : NSObject {
    
    let softwareBoundaryDictionary = [String : Int]()
    
    
    // return the application name of the front most one
    func frontmostApplication() -> String{
        let frontMostApplicationName = NSWorkspace.shared.frontmostApplication?.localizedName?.description
        print("current front most application is:", frontMostApplicationName!)
        return frontMostApplicationName!
    }
    
    
    // return all running applications
    func openingApplication(){
        
        // let openingApplicationList = NSWorkspace.shared.runningApplications.description
        for runningApp in NSWorkspace.shared.runningApplications {
            if (runningApp.isHidden){
                print(runningApp, "is hidden")
            }
            else {
                print(runningApp.localizedName!)
            }
        }
    }
    
    func test(imageInfor : screenshotCaptureRegion) {
        let temp = CGWindowListCopyWindowInfo(.optionOnScreenAboveWindow, CGWindowID(0))
        var applicationNameStack = [String]()
        let infoList = temp as! [[String:Any]]
        let softwareNameList = infoList.filter{ ($0["kCGWindowLayer"] as! Int == 0) && ($0["kCGWindowOwnerName"] as? String != nil) }
        
        // print("softwarenamelist", softwareNameList)
        // print(type(of: softwareNameList))
        
        print("kcgWindowName is not nil and the number of the opening software is: ", softwareNameList.count)
        
        var allApplicationNmaeList = [String]()
        var allApplicationPIDList = [String]()
        for singleApplication in softwareNameList {
            let singleApplicationName = singleApplication["kCGWindowOwnerName"] as! String
            // print("PID", singleApplication["kCGWindowOwnerPID"] ?? "PID value is nil")
            let singleApplicationPIDName = String(describing: singleApplication["kCGWindowOwnerPID"])
            
            if (!allApplicationPIDList.contains(singleApplicationPIDName)){
                if singleApplicationName != "universalAccessAuthWarn" {
                    allApplicationNmaeList.append(singleApplicationName)
                    allApplicationPIDList.append(singleApplicationPIDName)
                }
            }
        }
        print("opened software name list in order: ", allApplicationNmaeList)
    }
    
    func getOpenningSoftwareInformation() -> Array<Dictionary<String, Any>>{
        let temp = CGWindowListCopyWindowInfo(.optionOnScreenAboveWindow, CGWindowID(0))
        var applicationNameStack = [String]()
        let infoList = temp as! [[String:Any]]
        let softwareNameList = infoList.filter{ ($0["kCGWindowLayer"] as! Int == 0) && ($0["kCGWindowOwnerName"] as? String != nil) }
        // print("softwarenamelist", softwareNameList)
        return softwareNameList
    }
    
    func getOpenningApplicationThroughNSWork(){
        let ws = NSWorkspace.shared
        
        let apps = ws.runningApplications
        for currentApp in apps
        {
            if(currentApp.activationPolicy == .regular){
                print(currentApp.localizedName!)
            }
        }
        
    }
    
    // get opened running application name list
    func getOpenedRunningApplicaionNameList(imageInfor: screenshotCaptureRegion, wholeInfor : inout screenshotInformation) -> Array<String>{
        
        getOpenningApplicationThroughNSWork()
        
        let screenshotWidth = imageInfor.screenshotRegion["Width"]
        let screenshotHeight = imageInfor.screenshotRegion["Height"]
        let screenshotleft = imageInfor.screenshotRegion["Left"]
        let screenshotRight = imageInfor.screenshotRegion["Right"]
        let screenshotTop = imageInfor.screenshotRegion["Top"]
        let screenshotBottom = imageInfor.screenshotRegion["Bottom"]
        
        print(type(of: wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"]))
        
        let areaOfScreenshot = calculateAreaOfScreenshot(width: screenshotWidth!, height: screenshotHeight!)
        print("area of screenshot is: ", areaOfScreenshot)
        
        var wholeScreenSet = initialWholeScreenMatrix()
        var visibleApplicationNameStack = [String]()
        
        
        // copy values from wholeInfor
        var temtwholeInfor = wholeInfor
        
//        let temp = CGWindowListCopyWindowInfo(.optionOnScreenAboveWindow, CGWindowID(0))
//        let windowsInformationList = temp as! [[String:Any]]
//        let softwareInformationList = windowsInformationList.filter{ ($0["kCGWindowLayer"] as! Int == 0) && ($0["kCGWindowOwnerName"] as? String != nil) }
//        print("softwarenamelist", softwareInformationList)
//        print("kcgWindowName is not nil and the number of the opening software is: ", softwareInformationList.count)
        
        var allApplicationNameList = [String]()
        var allApplicationPIDList = [String]()
        let softwareInformationList = getOpenningSoftwareInformation()
        
        for singleApplication in softwareInformationList {
            let singleApplicationName = singleApplication["kCGWindowOwnerName"] as! String
            // print("PID", singleApplication["kCGWindowOwnerPID"] ?? "PID value is nil")
            let singleApplicationPIDName = String(describing: singleApplication["kCGWindowOwnerPID"])
            if (!allApplicationPIDList.contains(singleApplicationPIDName)){
                if singleApplicationName != "universalAccessAuthWarn" {
                    allApplicationNameList.append(singleApplicationName)
                    allApplicationPIDList.append(singleApplicationPIDName)
                }
            }
        }
        print("opened software name list in order: ", allApplicationNameList)
        
        
        

        var allApplicationsCoordinates = [String: [String]]()

        // save this name list as a global variable
        capturedScreenshotInformation.capturedApplicationNameArray = allApplicationNameList

        // reverse the softwareNameList from the behind most to front most
        let softwareNameListTemp = softwareInformationList
        let softwareNameListReverse = softwareNameListTemp.reversed()
        
        print(softwareNameListReverse.count)
        
        // dictionary to map appIndex and application name
        var applicationNamesWithIndex = [Int : String]()
        
        // check every software in this list
        for (appIndex, simpleSoftware) in softwareNameListReverse.enumerated() {
            

            let applicationName = simpleSoftware["kCGWindowOwnerName"] as! String
            let applicationBounds = simpleSoftware["kCGWindowBounds"]
            
            
            print("application index and name: ", appIndex, applicationName)
            applicationNamesWithIndex.updateValue(applicationName, forKey: appIndex)
            
            if (applicationName == "universalAccessAuthWarn"){
                continue
            }

            // code here
            // check negative values in applicationBounds
            // 
            
            /*
            {
             Height = 900;
             Width = 1440;
             X = 0;
             Y = 0;
             }
            */

            let boundDictionaryFormat = applicationBounds as! NSDictionary
            // print("software name is: ", applicationName)

            if (applicationName == "universalAccessAuthWarn"){
                // if the captured application is system preference, do nothing
            }
            else {

                print(applicationName)
                print("bounds in dictionary format", boundDictionaryFormat)
                // dictionary.count == 4

                var upperLeftXCoordination          = Int()
                var upperLeftYCoordination          = Int()
                var initialHeight                   = Int()
                var initialWidth                    = Int()

                var bottomRightXCoordination        = Int()
                var bottomRightYCoordination        = Int()


                // extract coordination values for each captured application
                for (key, vaule) in boundDictionaryFormat {

                    if (key as! String) == "X" {
                        upperLeftXCoordination = (boundDictionaryFormat.value(forKey: "X") as! Int)
                        // print("the value of firstX is: ", firstX!)
                    }

                    else if (key as! String) == "Y" {
                        upperLeftYCoordination = ( boundDictionaryFormat.value(forKey: "Y") as! Int )
                        // print("the value of firstY is: ", firstY!)
                    }

                    else if (key as! String == "Width"){
                        initialWidth = (boundDictionaryFormat.value(forKey: "Width") as! Int)
                        // print("the value of secondX is: ", secondX!)
                    }

                    else if (key as! String == "Height"){
                        initialHeight =  (boundDictionaryFormat.value(forKey: "Height") as! Int)
                        // print("the value of secondY is: ", secondY!)
                    }
                    // get the bound information separately
                    /*
                     X 1440
                     Height 1080
                     Y 0
                     Width 1920
                     */
                }
                

                // set the coordination for bottom right point
                bottomRightXCoordination = upperLeftXCoordination + initialWidth
                bottomRightYCoordination = upperLeftYCoordination + initialHeight

                // x, go right, becomes greater
                // y, go down, becomes greater
                //
                // (left, top) (right, bottom)
                // (upperLeftXCoordination, upperLeftYCoordination) (bottomRightXCoordination, bottomRightYCoordination)

                // coonsider all cases
                // screenshotleft, screenshotRight, screenshotTop, screenshotBottom
                // (left, top) ------ (right, top)
                //  |                       |
                // (left, bottom)-----(right, bottom)
                
                // bottomRightXCoordination,bottomRightYCoordination
                // upperLeftXCoordination, upperLeftYCoordination
                
                var applicationWindowSet = initialApplicationWindowMatrix(w: initialWidth, h: initialHeight)
                var currentApplicationInforStuct = applicationInformation()
                currentApplicationInforStuct.singleApplicationInforTemplate["Left"] = upperLeftXCoordination
                currentApplicationInforStuct.singleApplicationInforTemplate["Top"] = upperLeftYCoordination
                currentApplicationInforStuct.singleApplicationInforTemplate["Right"] = bottomRightXCoordination
                currentApplicationInforStuct.singleApplicationInforTemplate["Bottom"] = bottomRightYCoordination
                currentApplicationInforStuct.singleApplicationInforTemplate["ApplicationName"] = applicationName
                var tempDic = wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
                
                
                //
                
                
                print("application left" + String(upperLeftXCoordination))
                print("application top" + String(upperLeftYCoordination))
                print("application right" + String(bottomRightXCoordination))
                print("application bottom" + String(bottomRightYCoordination))
                print("screenshot left" + String(screenshotleft!))
                print("screenshot top" + String(screenshotTop!))
                print("screenshot right" + String(screenshotRight!))
                print("screenshot bottom" + String(screenshotBottom!))
                
                
                print("application index is :" + String(appIndex))
                // case 1: screenshot is bigger than applicaiton area
                if(screenshotleft! < upperLeftXCoordination && screenshotTop! < upperLeftYCoordination && screenshotRight! > bottomRightXCoordination && screenshotBottom! > bottomRightYCoordination){
                    print("case 1")
                    // set the matrix

                    let startRow = Int(upperLeftYCoordination) as Int
                    let endRow = Int(bottomRightYCoordination) as Int
                    let startCol = Int(upperLeftXCoordination) as Int
                    let endCol = Int(bottomRightXCoordination) as Int
                    let indexInterval = Int(1)
                    for row in stride(from: startRow, through: endRow, by: indexInterval){
                        for col in stride(from: startCol, through: endCol, by: indexInterval){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    
                    // append this application information
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                    
                }
                // case 2: screenshot is contained in the application area
                else if (screenshotleft! > upperLeftXCoordination && screenshotTop! > upperLeftYCoordination && screenshotRight! < bottomRightXCoordination && screenshotBottom! < bottomRightYCoordination){
                    print("case 2")
                    // set the matrix
                    let startRow = Int(screenshotTop!) as Int
                    let endRow = Int(screenshotBottom!) as Int
                    let startCol = Int(screenshotleft!) as Int
                    let endCol = Int(screenshotRight!) as Int
                    let intervalValue = Int(1)
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                }
                
                // case 3: application bottom right point is inside the screenshot
                else if (upperLeftXCoordination < screenshotleft! && upperLeftYCoordination < screenshotTop! && bottomRightXCoordination > screenshotleft! && bottomRightYCoordination > screenshotTop! && bottomRightXCoordination < screenshotRight! && bottomRightYCoordination < screenshotBottom!){
                    
                    print("case 3")
                    let startRow = Int(screenshotTop!) as Int
                    let endRow = Int(bottomRightYCoordination) as Int
                    let startCol = Int(screenshotleft!) as Int
                    let endCol = Int(bottomRightXCoordination) as Int
                    let intervalValue = Int(1)
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    

                }
                // case 4: application upper right point is inside  the screenshot
                else if (upperLeftXCoordination < screenshotleft! && bottomRightYCoordination > screenshotBottom! && bottomRightXCoordination > screenshotleft! && upperLeftYCoordination < screenshotBottom! && bottomRightXCoordination < screenshotRight! && upperLeftYCoordination > screenshotTop!){
                    
                    let startRow = Int(upperLeftYCoordination) as Int
                    let endRow = Int(screenshotBottom!) as Int
                    let startCol = Int(screenshotleft!) as Int
                    let endCol = Int(bottomRightXCoordination) as Int
                    let intervalValue = Int(1)
                    print("case 4")
                    
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                
                // case 5: application bottom left point is inside the screenshot
                else if(upperLeftXCoordination > screenshotleft! && bottomRightYCoordination < screenshotBottom! && bottomRightXCoordination > screenshotRight! && upperLeftYCoordination < screenshotTop! && upperLeftXCoordination < screenshotRight! && bottomRightYCoordination > screenshotTop!){
                    
                    
                    let startRow = Int(screenshotTop!) as Int
                    let endRow = Int(bottomRightYCoordination) as Int
                    let startCol = Int(upperLeftXCoordination) as Int
                    let endCol = Int(screenshotRight!) as Int
                    let intervalValue = Int(1)
                    
                    print("case 5")
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                // case 6: application upper left point is inside the screenshot
                
                else if (upperLeftXCoordination > screenshotleft! && upperLeftYCoordination > screenshotTop! && upperLeftXCoordination < screenshotRight! && upperLeftYCoordination < screenshotBottom! && bottomRightXCoordination > screenshotRight! && bottomRightYCoordination > screenshotBottom!){

                    
                    let startRow = Int(upperLeftYCoordination) as Int
                    let endRow = Int(screenshotBottom!) as Int
                    let startCol = Int(upperLeftXCoordination) as Int
                    let endCol = Int(screenshotRight!) as Int
                    let intervalValue = Int(1)
                    
                    print("case 6")
                    
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                
                // case 7: application right edge is crossed with screenshot
                else if(bottomRightXCoordination > screenshotleft! && bottomRightXCoordination < screenshotRight! && screenshotleft! > upperLeftXCoordination){
                    let minTop = min(upperLeftYCoordination, screenshotTop!)
                    let minBot = min(bottomRightYCoordination, screenshotBottom!)
                    let startCol = Int(screenshotleft!) as Int
                    let endCol = Int(bottomRightXCoordination) as Int
                    let intervalValue = Int(1)
                    
                    for row in stride(from: minTop, through: minBot, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 7")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                // case 8: application left edge is crossed with screenshot
                else if (screenshotleft! < upperLeftXCoordination && upperLeftXCoordination < screenshotRight! && screenshotRight! < bottomRightXCoordination){
                    
                    let minTop = min(upperLeftYCoordination, screenshotTop!)
                    let minBot = min(bottomRightYCoordination, screenshotBottom!)
                    let startCol = Int(upperLeftXCoordination) as Int
                    let endCol = Int(screenshotRight!) as Int
                    let intervalValue = Int(1)
                    for row in stride(from: minTop, through: minBot, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 8")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                // case 9: application bottom edge is crossed with screenshot
                else if(bottomRightYCoordination > screenshotTop! && bottomRightYCoordination < screenshotBottom! && upperLeftYCoordination > screenshotTop!){
                    
                    let minLeft = min(screenshotleft!, upperLeftXCoordination)
                    let minRight = min(screenshotRight!, bottomRightXCoordination)
                    let startRow = Int(screenshotTop!) as Int
                    let endRow = Int(upperLeftYCoordination) as Int
                    let intervalValue = Int(1)
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: minLeft, through: minRight, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 9")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                    
                }
                // case 10: application top edge is crossed with screenshot
                else if(upperLeftYCoordination > screenshotTop! && upperLeftYCoordination < screenshotBottom! && bottomRightYCoordination > screenshotBottom!){
                    
                    let minLeft = min(screenshotleft!, upperLeftXCoordination)
                    let minRight = min(screenshotRight!, bottomRightXCoordination)
                    let startRow = Int(upperLeftYCoordination) as Int
                    let endRow = Int(screenshotBottom!) as Int
                    let intervalValue = Int(1)
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: minLeft, through: minRight, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 10")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                // case 11: application right and left edges are crossed with screenshot
                else if (upperLeftXCoordination > screenshotleft! && bottomRightXCoordination < screenshotRight! && upperLeftYCoordination > screenshotTop! && bottomRightYCoordination > screenshotBottom!){
                    
                    let intervalValue = Int(1)
                    let startRow = Int(screenshotTop!) as Int
                    let endRow = Int(screenshotBottom!) as Int
                    let startCol = Int(upperLeftXCoordination) as Int
                    let endCol = Int(bottomRightXCoordination) as Int
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 11")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                }
                // case 12: application bottom and top edges are crossed with screenshot
                else if (upperLeftYCoordination > screenshotTop! && bottomRightYCoordination < screenshotBottom! && upperLeftXCoordination < screenshotleft! && bottomRightXCoordination > screenshotRight!){
                    
                    let intervalValue = Int(1)
                    let startRow = Int(upperLeftYCoordination) as Int
                    let endRow = Int(bottomRightYCoordination) as Int
                    let startCol = Int(screenshotleft!) as Int
                    let endCol = Int(screenshotRight!) as Int
                    
                    for row in stride(from: startRow, through: endRow, by: intervalValue){
                        for col in stride(from: startCol, through: endCol, by: intervalValue){
                            wholeScreenSet[row][col] = appIndex
                        }
                    }
                    print("case 12")
                    // finish the matrix calculation
                    
                    tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                    wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                    
                    
                }
                
                // two rectangles have no overlapping area
                else{
                    // do nothing
                    print("case 13, no overlapping at all")
                    continue
                }
                
            }

        }
        
        

        var tempVisiableApplicationIndexSet = Set<Int>()
        let startRow = Int(screenshotTop!) as Int
        let endRow = Int(screenshotBottom!) as Int
        let startCol = Int(screenshotleft!) as Int
        let endCol = Int(screenshotRight!) as Int
        for row in stride(from: startRow, through: endRow, by: Int(1)){
            for col in stride(from: startCol, through: endCol, by: Int(1)){
                if (wholeScreenSet[row][col] != -1){
                    if(!tempVisiableApplicationIndexSet.contains(wholeScreenSet[row][col])){
                        tempVisiableApplicationIndexSet.insert(wholeScreenSet[row][col])
                    }
                }
            }
        }
        print(tempVisiableApplicationIndexSet.count)
        for index in tempVisiableApplicationIndexSet{
            print("application index: ", index)
        }
        for number in tempVisiableApplicationIndexSet{
            let tempAppName = applicationNamesWithIndex[number]
            visibleApplicationNameStack.append(tempAppName ?? "error happens in extracting index from set!")
        }


        print(visibleApplicationNameStack)
//        variables.recordedApplicationNameStack = applicationNameStack
//        variables.numberofRecordedApplication = applicationNameStack.count
//        alternativeUserInterfaceVariables.capturedApplicationNumber = applicationNameStack.count
        
        return visibleApplicationNameStack

        
    }
    
    func getOpenedRunningApplicaionNameListWithBitMasking(imageInfor: screenshotCaptureRegion, wholeInfor : inout screenshotInformation) -> Array<String>{
        
        var visibleApplicationNameStack = [String]()
        
        // from 1 to ? min(height, width)
        var downSampleRatio = Float()
        
        // default value is 1.0
        // 50
        downSampleRatio = 7.0
        
        
        var screenshotWidth = imageInfor.screenshotRegion["Width"]!
        var screenshotHeight = imageInfor.screenshotRegion["Height"]!
        var screenshotleft = imageInfor.screenshotRegion["Left"]!
        var screenshotRight = imageInfor.screenshotRegion["Right"]!
        var screenshotTop = imageInfor.screenshotRegion["Top"]!
        var screenshotBottom = imageInfor.screenshotRegion["Bottom"]!
        
        
        var allApplicationNameList = [String]()
        var allApplicationPIDList = [String]()
        let softwareInformationList = getOpenningSoftwareInformation()
        
        for singleApplication in softwareInformationList {
            let singleApplicationName = singleApplication["kCGWindowOwnerName"] as! String
            print("PID", singleApplication["kCGWindowOwnerPID"] ?? "PID value is nil")
            let singleApplicationPIDName = String(describing: singleApplication["kCGWindowOwnerPID"])
            if (!allApplicationPIDList.contains(singleApplicationPIDName)){
                if singleApplicationName != "universalAccessAuthWarn" {
                    allApplicationNameList.append(singleApplicationName)
                    allApplicationPIDList.append(singleApplicationPIDName)
                }
            }
        }
        print("opened software name list in order: ", allApplicationNameList)
        
        let softwareNameListTemp = softwareInformationList
        
        // get the main screen paramters, width and height
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        var mainScreenHeight = Int(rectArea.size.height)
        var mainScreenWidth = Int(rectArea.size.width)
        
//        print(mainScreenWidth)
//        print(downSampleRatio)
        
        // down sample the whole screen size: screen height ans width
        let mainScreenHeightAfterDownSample = Float(mainScreenHeight) / Float(downSampleRatio)
        let mainScreenWidthAfterDownSample = Float(mainScreenWidth) / Float(downSampleRatio)
        
        
        // using ceiling funciton to round up for the whole screen width and height
        // print(type(of: mainScreenWidthAfterDownSample))
        mainScreenWidth = Int(ceilf(mainScreenWidthAfterDownSample))
        mainScreenHeight = Int(ceilf(mainScreenHeightAfterDownSample))
//        mainScreenHeight = Int(mainScreenHeightAfterDownSample)
//        mainScreenWidth = Int(mainScreenWidthAfterDownSample)
        
        
        
        // initial screenshot matrix
        // down sample screenshot's width and height
        let screenshotTopDownSample = Float(screenshotTop) / Float(downSampleRatio)
        let screenshotBottomDownSample = Float(screenshotBottom) / Float(downSampleRatio)
        let screenshotLeftDownSample = Float(screenshotleft) / Float(downSampleRatio)
        let screenshotRightDownSample = Float(screenshotRight) / Float(downSampleRatio)
        
        // round down the upper left coordinate
        // round up the bottom right coordinate(ceil)
        screenshotTop = Int(floorf(screenshotTopDownSample))
        screenshotleft = Int(floorf(screenshotLeftDownSample))
        screenshotBottom = Int(ceilf(screenshotBottomDownSample))
        screenshotRight = Int(ceilf(screenshotRightDownSample))
        
//        screenshotTop = Int(screenshotTopDownSample)
//        screenshotBottom = Int(screenshotBottomDownSample)
//        screenshotleft = Int(screenshotLeftDownSample)
//        screenshotRight = Int(screenshotRightDownSample)
        
        
        
        var basicMatrix = initialScreenshotMatrixInWholeScreen(wholeWidth: mainScreenWidth, wholeHeight: mainScreenHeight, startRow: screenshotTop, endRow: screenshotBottom, startCol: screenshotleft, endCol: screenshotRight)
        
        
        for (appIndex, simpleSoftware) in softwareNameListTemp.enumerated() {
            let applicationName = simpleSoftware["kCGWindowOwnerName"] as! String
            let applicationBounds = simpleSoftware["kCGWindowBounds"]
            
            let kCGWindowAlphaValue = simpleSoftware["kCGWindowAlpha"] as! Float
            
            print("application index and name: ", appIndex, applicationName)
            
            
            let boundDictionaryFormat = applicationBounds as! NSDictionary
            // print("software name is: ", applicationName)
            
            
            if (applicationName == "universalAccessAuthWarn"){
                continue
            }
                
            else if (kCGWindowAlphaValue == Float(0.0)){
                // kCGWindowAlpha should be greater than 0.0 or equals to 1.0
                // now, I compare it with 0.0
                // https://developer.apple.com/documentation/coregraphics/kcgwindowalpha?language=objc
                continue
            }

            /*
            {
             Height = 900;
             Width = 1440;
             X = 0;
             Y = 0;
             }
            */


            else {
                
                var upperLeftXCoordination          = Int()
                var upperLeftYCoordination          = Int()
                var initialHeight                   = Int()
                var initialWidth                    = Int()

                var bottomRightXCoordination        = Int()
                var bottomRightYCoordination        = Int()


               // extract coordination values for each captured application
                for (key, vaule) in boundDictionaryFormat {

                    if (key as! String) == "X" {
                       upperLeftXCoordination = (boundDictionaryFormat.value(forKey: "X") as! Int)
                       // print("the value of firstX is: ", firstX!)
                    }

                    else if (key as! String) == "Y" {
                       upperLeftYCoordination = ( boundDictionaryFormat.value(forKey: "Y") as! Int )
                       // print("the value of firstY is: ", firstY!)
                    }

                    else if (key as! String == "Width"){
                       initialWidth = (boundDictionaryFormat.value(forKey: "Width") as! Int)
                       // print("the value of secondX is: ", secondX!)
                    }

                    else if (key as! String == "Height"){
                       initialHeight =  (boundDictionaryFormat.value(forKey: "Height") as! Int)
                       // print("the value of secondY is: ", secondY!)
                    }
                   // get the bound information separately
                   /*
                    X 1440
                    Height 1080
                    Y 0
                    Width 1920
                    */
                }
                
                bottomRightXCoordination = upperLeftXCoordination + initialWidth
                bottomRightYCoordination = upperLeftYCoordination + initialHeight
                
                var applicationTop = upperLeftYCoordination
                var applicationBottom = bottomRightYCoordination
                var applicationLeft = upperLeftXCoordination
                var applicationRight = bottomRightXCoordination
                
                // down sample the current applicaiton boundary
                let applicationTopDownSample = Float(applicationTop) / Float(downSampleRatio)
                let applicationBottomDownSample = Float(applicationBottom) / Float(downSampleRatio)
                let applicationLeftDownSample = Float(applicationLeft) / Float(downSampleRatio)
                let applicationRightDownSample = Float(applicationRight) / Float(downSampleRatio)
                
                
                // round down the upper left coordinate
                // round up the bottom right coordinate(ceil)
                applicationTop = Int(floorf(applicationTopDownSample))
                applicationLeft = Int(floorf(applicationLeftDownSample))
                applicationRight = Int(ceilf(applicationRightDownSample))
                applicationBottom = Int(ceilf(applicationBottomDownSample))

//                applicationTop = Int(applicationTopDownSample)
//                applicationBottom = Int(applicationBottomDownSample)
//                applicationLeft = Int(applicationLeftDownSample)
//                applicationRight = Int(applicationRightDownSample)
                
                
                
                // applicaiton matrix in the whole screen
                let applicationMatrixInWholeScreen = initialApplicationMatrixInWholeScreen(wholeWidth: mainScreenWidth, wholeHeight: mainScreenHeight, startRow: applicationTop, endRow: applicationBottom, startCol: applicationLeft, endCol: applicationRight)
                
                // after and operation between screenshot matrix and application matrix in the whole screen
                let overlappingMatrixWithAndOperation = twoMatricesAndCalculating(screenshotMatrix: basicMatrix, applicationMatrix: applicationMatrixInWholeScreen)
                
                // overlapping area > 0, means overlapped
                if(overlappingArea(matrix: overlappingMatrixWithAndOperation) > 0){
                    visibleApplicationNameStack.append(applicationName)
                }
                
                 // x, go right, becomes greater
                 // y, go down, becomes greater
                 //
                 // (left, top) (right, bottom)
                 // (upperLeftXCoordination, upperLeftYCoordination) (bottomRightXCoordination, bottomRightYCoordination)

                 // coonsider all cases
                 // screenshotleft, screenshotRight, screenshotTop, screenshotBottom
                 // (left, top) ------ (right, top)
                 //  |                       |
                 // (left, bottom)-----(right, bottom)
                
                 // bottomRightXCoordination,bottomRightYCoordination
                 // upperLeftXCoordination, upperLeftYCoordination
                 
                 // get the current screenshot information of "Application Information"
                 var tempDic = wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
                 
                 var currentApplicationInforStuct = applicationInformation()
                 currentApplicationInforStuct.singleApplicationInforTemplate["Left"] = upperLeftXCoordination
                 currentApplicationInforStuct.singleApplicationInforTemplate["Top"] = upperLeftYCoordination
                 currentApplicationInforStuct.singleApplicationInforTemplate["Right"] = bottomRightXCoordination
                 currentApplicationInforStuct.singleApplicationInforTemplate["Bottom"] = bottomRightYCoordination
                 currentApplicationInforStuct.singleApplicationInforTemplate["ApplicationName"] = applicationName
                 
                 
                 // append this visiable applicaiton inforamtion to the struct
                 tempDic.append(currentApplicationInforStuct.singleApplicationInforTemplate)
                 // rewrite
                 wholeInfor.metaDataSingleRecordingTemplate["ApplicationInformation"] = tempDic
                
                
                
                // subtract overlapping area from the basic matrix
                let overlappingMatrixWithSubtractOperation = twoMatricesSubtractCalculating(screenshotMatrix: basicMatrix, applicationMatrix: overlappingMatrixWithAndOperation)
                
                let remainAreaInWholeScreen = calculatingOnesSum(matrix: overlappingMatrixWithSubtractOperation)
                
                if (remainAreaInWholeScreen == 0){
                    // no area left for the next application to see
                    // break from the for loop
                    break
                }
                
                // reset the basicMatrix
                basicMatrix = overlappingMatrixWithSubtractOperation
                
                // visibleApplicationNameStack.append(applicationName)
                
                
            }
            // end of for loop
        }
        
        
        print("visiable application names with bit masking algorithm")
        print(visibleApplicationNameStack)
        
        
        return visibleApplicationNameStack
    }

    
    func calculateAreaOfScreenshot(width: Int, height: Int) -> Int{
        return width * height
    }
    
    func initialWholeScreenMatrix() -> [[Int]] {
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        let mainScreenHeight = Int(rectArea.size.height)
        let mainScreenWidth = Int(rectArea.size.width)
        let wholeScreenMatrix = [[Int]](repeating: [Int](repeating: -1, count: mainScreenWidth), count: mainScreenHeight)
//        print(wholeScreenMatrix.count)
//        print(wholeScreenMatrix[0].count)
        print(wholeScreenMatrix[200][300])
        return wholeScreenMatrix
    }
    
    func initialApplicationWindowMatrix(w : Int, h : Int) ->[[Int]]{
        // h(height) is row, w(width) is column
        let applicationWindowMatrix = [[Int]](repeating: [Int](repeating: -1, count: w), count: h)
        return applicationWindowMatrix
    }
    
    
    func initialScreenshotMatrixInWholeScreen(wholeWidth: Int, wholeHeight: Int, startRow: Int, endRow: Int, startCol : Int, endCol: Int) -> [[Int]]{
        var screenshotMatrix = [[Int]](repeating: [Int](repeating: 0, count: wholeWidth), count: wholeHeight)
        
        var newStartRow = startRow
        var newEndRow = endRow
        var newStartCol = startCol
        var newEndCol = endCol
        
        if(newStartRow < 0){
            newStartRow = 0
        }
        if(newStartCol < 0){
            newStartCol = 0
        }
        if(newEndRow > wholeHeight){
            newEndRow = wholeHeight
        }
        if(newEndCol > wholeWidth){
            newEndCol = wholeWidth
        }
        
        for i in newStartRow..<newEndRow{
            for j in newStartCol..<newEndCol{
                screenshotMatrix[i][j] = 1
            }
        }
        
        return screenshotMatrix
    }
    
    func initialApplicationMatrixInWholeScreen(wholeWidth: Int, wholeHeight: Int, startRow: Int, endRow: Int, startCol: Int, endCol: Int) -> [[Int]]{
        var applicationMatrix = [[Int]](repeating: [Int](repeating: 0, count: wholeWidth), count: wholeHeight)
        var newStartRow = startRow
        var newEndRow = endRow
        var newStartCol = startCol
        var newEndCol = endCol
        
        if(newStartRow < 0){
            newStartRow = 0
        }
        if(newStartCol < 0){
            newStartCol = 0
        }
        if(newEndRow > wholeHeight){
            newEndRow = wholeHeight
        }
        if(newEndCol > wholeWidth){
            newEndCol = wholeWidth
        }
        
        // initial solution
        // corner case: screen size: 1440 * 900
        // basic matrix has no row 900 and column 1440
        // application size: 1440 * 900
        for i in newStartRow..<newEndRow{
            for j in newStartCol..<newEndCol{
                applicationMatrix[i][j] = 1
            }
        }
        return applicationMatrix
    }
    
    
    func twoMatricesAndCalculating(screenshotMatrix: [[Int]], applicationMatrix: [[Int]]) ->[[Int]]{
        var overlappedMatrix = screenshotMatrix
        
        let height = screenshotMatrix.count
        let width = screenshotMatrix[0].count
        
        for i in 0..<height{
            for j in 0..<width{
                overlappedMatrix[i][j] = screenshotMatrix[i][j] & applicationMatrix[i][j]
//                if (screenshotMatrix[i][j] == 1 && applicationMatrix[i][j] == 1){
//                    overlappedMatrix[i][j] = 1
//                }
            }
        }
        
        return overlappedMatrix
    }
    
    
    func twoMatricesSubtractCalculating(screenshotMatrix: [[Int]], applicationMatrix: [[Int]]) ->[[Int]]{
        var overlappedMatrix = screenshotMatrix
        let height = screenshotMatrix.count
        let width = screenshotMatrix[0].count
        
        for i in 0..<height{
            for j in 0..<width{
                overlappedMatrix[i][j] = screenshotMatrix[i][j] - applicationMatrix[i][j]
            }
        }
        return overlappedMatrix
    }
    
    func overlappingArea(matrix: [[Int]]) -> Int{
        var result = 0
        let height = matrix.count
        let width = matrix[0].count
        for i in 0..<height{
            for j in 0..<width{
                if (matrix[i][j] == 1){
                    result = result + 1
                }
            }
        }
        return result
    }
    
    func calculatingOnesSum(matrix: [[Int]]) -> Int{
        var result = 0
        let height = matrix.count
        let width = matrix[0].count
        for i in 0..<height{
            for j in 0..<width{
                if (matrix[i][j] == 1){
                    result = result + 1
                }
            }
        }
        return result
    }
    
}
