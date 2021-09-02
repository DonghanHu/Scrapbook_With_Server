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
    
    // get opened running application name list
    func getOpenedRunningApplicaionNameList() -> Array<String>{
        
        let rawData = CGWindowListCopyWindowInfo(.optionOnScreenAboveWindow, CGWindowID(0))
        
        // array save application names
        var applicationNameStack = [String]()
        //let widowsListenInfor = CGWindowListCopyWindowInfo(option: optionOnScreenAboveWindow, CGWindowID(0))
        
        // format rawData into an array
        let inforList = rawData as! [[String:Any]]
        
        // extrct name list from the inforList array
        var softwareNameList = inforList.filter{ ($0["kCGWindowLayer"] as! Int == 0) && ($0["kCGWindowOwnerName"] as? String != nil) }
        // the name list is from the front most to behind ones
        print("softwarenamelist", softwareNameList)

        // the sum of the applications' area
        var totoalRectArea = 0
        
        // var overlappedAreaWithLastLayer = 0
        
        var tempFirstx      = 0
        var tempFirstY      = 0
        var tempSecondX     = 0
        var tempSecondY     = 0
        
        print("kcgWindowName is not nil and the number of the opening software is: ", softwareNameList.count)
        
        
        var allApplicationNameList = [String]()
        var allApplicationPIDList = [String]()
        
        
        for singleApplication in softwareNameList {
            let singleApplicationName = singleApplication["kCGWindowOwnerName"] as! String
            // print("PID", singleApplication["kCGWindowOwnerPID"] ?? "PID value is nil")
            let singleApplicationPIDName = String(describing: singleApplication["kCGWindowOwnerPID"])
            
            if (!allApplicationPIDList.contains(singleApplicationPIDName)){
                if singleApplicationName != "universalAccessAuthWarn" {
                    // add application name and corresponding PID name into two arrays
                    allApplicationNameList.append(singleApplicationName)
                    allApplicationPIDList.append(singleApplicationPIDName)
                }
            }
            
        }
        
        print("opened running software name in order: ", allApplicationNameList)
        
        var allApplicationsCoordinates = [String: [String]]()
        
        // save this name list as a global variable
        capturedScreenshotInformation.capturedApplicationNameArray = allApplicationNameList

        // check every software in this list
        for simpleSoftware in softwareNameList {
            
            let applicationName = simpleSoftware["kCGWindowOwnerName"] as! String
            let applicationBounds = simpleSoftware["kCGWindowBounds"]

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
                // print("bounds in dictionary format", boundDictionaryFormat)
                // dictionary.count == 4
                
                var upperLeftXCoordination    = Int()
                var upperLeftYCoordination    = Int()
                var initialHeight           = Int()
                var initialWidth            = Int()
                
                var bottomRightXCoordination           = Int()
                var bottomRightYCoordination           = Int()
                
                var firstX  : Int!
                var firstY  : Int!
                var height  : Int!
                var width   : Int!
                var secondX : Int!
                var secondY : Int!
                
                var newFirstX   : Int!
                var newFirstY   : Int!
                var newSecondX  : Int!
                var newSecondY  : Int!
                
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
                
//                var tempStringArray = [String]()
//                tempStringArray.append(applicationName)
//                tempStringArray.append(String(firstX))
//                tempStringArray.append(String(firstY))
//                tempStringArray.append(String(width))
//                tempStringArray.append(String(height))
//                var tempDic = [applicationName: tempStringArray] as NSDictionary
                
                // capturedApplicationsCoordinates.caputredCoordinates.merge(dict: tempDic as! [String : [String]])
                
                // get the first and second coordination of the openning application
                
//                print("software first x position: ", firstX!)
//                print("software first y position: ", firstY!)
//                print("software second x position: ", secondX!)
//                print("software second y position: ", secondY!)

                
                
                // calculate the area of screenshot
                // pass struct here later
                let areaOfScreenshot = calculateAreaOfScreenshot(width: 960, height: 1440)
                print("area of screenshot is: ", areaOfScreenshot)
                
                
                // x, go right, becomes greater
                // y, go down, becomes greater
                //
                // (left, top) (right, bottom)
                // (upperLeftXCoordination, upperLeftYCoordination) (bottomRightXCoordination, bottomRightYCoordination)
                
                let x5 = max(screenShotInformation.firstCoordinationOfX, firstX)
                let y5 = max(screenShotInformation.firstCoordinationOfY, firstY)
                let x6 = min(screenShotInformation.secondCoordinationOfX, secondX)
                let y6 = min(screenShotInformation.secondCoordinationOfY, secondY)

                // coonsider all cases
                // case 1: if two rectangles have no overlapping area
                if()
                
                // case 2: two rectangles overlap with each other
                
                // changed here
                // if (x5 > x6) || (y5 > y6){
                if (x5 > x6) && (y5 > y6){
                    print("no overlapping between screenshot and this application")
                    continue
                }
                else if ((x5 > x6) || (y5 > y6)){
                    print("(x5 > x6) || (y5 > y6)")
                }
                else {
                    newFirstX = x5
                    newFirstY = y5
                    newSecondX = x6
                    newSecondY = y6
                    print("newFirstX: ", newFirstX!)
                    print("newFirstY: ", newFirstY!)
                    print("newSecondX:  ", newSecondX!)
                    print("newSecondY: ", newSecondY!)
                }
                
                
                let IntersectedArea = abs(newFirstX - newSecondX) * abs(newFirstY - newSecondY)
                print("Intersected Area is: ", IntersectedArea)
                print("tempFirstX: ", tempFirstx)
                print("tempFirstY: ", tempFirstY)
                print("tempSecondX: ", tempSecondX)
                print("tempSecondY: ", tempSecondY)
                let tempArea = twoRectangleOverlapArea(x1: tempFirstx, x2: tempSecondX, x3: newFirstX, x4: newSecondX, y1: tempFirstY, y2: tempSecondY, y3: newFirstY, y4: newSecondY)
                print("temp area is: ", tempArea)
                let validArea = IntersectedArea - tempArea
                
                tempFirstx = newFirstX
                tempFirstY = newFirstY
                tempSecondX = newSecondX
                tempSecondY = newSecondY
                
                print("valid Area: ", validArea)
                if (Double(validArea) / Double(areaOfScreenshot)) > 0 {
                    print("valid / total area is: ", (Double(validArea) / Double(areaOfScreenshot)))
                    applicationNameStack.append(applicationName)
                }
                totoalRectArea = totoalRectArea + validArea
                print("totalRectArea is: ", totoalRectArea)
                if (Double(totoalRectArea) / Double(areaOfScreenshot)) >= 1 {
                    print("app total / total area is: ", (Double(totoalRectArea) / Double(areaOfScreenshot)))
                    break
                }
            }

        }
        
        
        
        
        print("application name list stack: ", applicationNameStack)
        print("all applications coordinates in selected part of screenshots", capturedApplicationsCoordinates.caputredCoordinates)
        variables.recordedApplicationNameStack = applicationNameStack
        variables.numberofRecordedApplication = applicationNameStack.count
        alternativeUserInterfaceVariables.capturedApplicationNumber = applicationNameStack.count
        return applicationNameStack

//        let softwareNameList1 = infoList1.filter{ ($0["kCGWindowLayer"] as! Int == 0) && ($0["kCGWindowOwnerName"] as? String != nil) }
//
//        print("kcgWindowName1 is not nil", softwareNameList1.count)
        //print("visibleWindows", visibleWindows)
    }

    func twoRectangleOverlapArea(x1 : Int, x2 : Int, x3 : Int, x4 : Int, y1 : Int, y2 : Int, y3 : Int, y4 : Int) -> Int{
        let x5 = max(x1, x3)
        let y5 = max(y1, y3)
        let x6 = min(x2, x4)
        let y6 = min(y2, y4)
        if (x5 > x6 || y5 > y6){
            print("two rectangles are not intersected with others")
            return 0
        }
        else {
           return (abs(x5 - x6) * abs(y5 - y6))
        }
        
    }
    
    func calculateAreaOfScreenshot(width: Int, height: Int) -> Int{
        return width * height
    }
    
}
