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
    var takeScreenshotSuccess = true
    
    var eventMonitor : EventMonitor?
    
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
    
    var top     = Int()
    var bottom  = Int()
    var left    = Int()
    var right   = Int()
    var width   = Int()
    var height  = Int()
    
    var screenshotCaseIndex = 1
    
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
    
    // Method of taking screenshot by using terminate command line code
    // /usr/sbin/screencapture
    // -m         only capture the main monitor, undefined if -i is set
    
    struct ScreenshotOutput {
        var output: String
        var status: Int32
        init(status: Int32, output: String) {
            self.status = status
            self.output = output
        }
    }
    
    func launchSync(launchPath: String, arguments: [String]) -> ScreenshotOutput {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let pipeFile = pipe.fileHandleForReading
        task.launch()
        
        let data = NSMutableData()
        while task.isRunning {
            data.append(pipeFile.availableData)
        }
        let output = String(data: data as Data, encoding: .utf8)!
        
        return ScreenshotOutput(status: task.terminationStatus, output: output)
    }
    
    func selectScreenCapture(){
        
        var screenshotStruct = screenshotInformation()
        // if debug
        print(screenshotStruct.metaDataSingleRecordingTemplate)
        // print(type(of: screenshotStruct))
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd,HH-mm-ss"
        let dateString = dateFormatter.string(from: date)
        let screenshotPicName = "Screenshot-" + dateString + ".jpeg"
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        print(capturedScreenshotInformation.capturedScreenshotPathString)
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)
        
        var simpleWholeInfor = ""
        
        screenshotStruct.metaDataSingleRecordingTemplate["TimeStamp"] = dateString
        screenshotStruct.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = false
        let screenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        screenshotStruct.metaDataSingleRecordingTemplate["ImagePath"] = screenshotPathString
        screenshotStruct.metaDataSingleRecordingTemplate["ScreenshotPictureName"] = screenshotPicName
        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = [] as! [[String : Any]]
        print(type(of: screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"]))
        
//        Wednesday, Sep 12, 2018
//        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
//        Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
//        let currentTime = dateFormatter.string(from: date)
//        variables.currentTimeInformation = currentTime
        
        var arguments = [String]();
        // arguments.append("-s")
        arguments.append("-i")
        arguments.append("-r")
                
        let tempScreenshotPath = capturedScreenshotInformation.capturedScreenshotPathString
        arguments.append(tempScreenshotPath)
//        task.arguments = arguments
        
//        let testOutput = launchSync(launchPath: "/usr/sbin/screencapture", arguments: arguments)
//        print(testOutput)
        
//        return;
        
        
        // task parameters
        let task = Process()
        task.currentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        task.launchPath = "/usr/sbin/screencapture"
        
        task.arguments = arguments
        
        print(task.launchPath)
        print(task.arguments)
        
        setvbuf(stdout, nil, _IONBF, 0)
        setvbuf(stdin, nil, _IOFBF, 0)

        
        let outpipe = Pipe()
        let outputData = NSMutableData()

        
        dup2(outpipe.fileHandleForReading.fileDescriptor,
        STDOUT_FILENO)
        dup2(outpipe.fileHandleForReading.fileDescriptor, STDIN_FILENO)
        
        var finalOutputData : String = ""
    
        task.standardOutput = outpipe
        task.standardError = outpipe
        //task.launch() // asynchronous call.
        task.launch()
        
//        setvbuf(stderr, nil, _IONBF, 0)
//        setvbuf(stdout, nil, _IONBF, 0)
//        dup2(outpipe.fileHandleForReading.fileDescriptor, STDERR_FILENO)
//        dup2(outpipe.fileHandleForReading.fileDescriptor, STDOUT_FILENO)
//
        let pipeFile = outpipe.fileHandleForReading

        let data = pipeFile.readDataToEndOfFile()
        
//        let secondsToDelay = 5.0
//        perform(#selector(timeDelay), with: nil, afterDelay: secondsToDelay)
        
        let tempResult = String(data: data, encoding: .ascii)!
        let rawResults = tempResult.components(separatedBy:"\"")
            
        print("ARRAY: ", rawResults)
        
        task.waitUntilExit()

        finalOutputData = tempResult
        print("finalOutputData", tempResult)
//        fflush(stdout)
       
        // let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        
    
        
        dialogOK(question: "tempD+" + finalOutputData, text: "Click OK to continue.")
        
        if(finalOutputData == nil){
            dialogOK(question: "outputdata is empty", text: "Click OK to continue.")
        }else{
            dialogOK(question: "size of: " + String(MemoryLayout.size(ofValue: finalOutputData)), text: "Click OK to continue.")
        }

        
        
        // let resultInformation = String(data: finalOutputData, encoding: .utf8)
        let resultInformation = finalOutputData
        // let tempScreenshotData = ( resultInformation! )
        let tempScreenshotData = resultInformation
        // print("output", output!)
        
        print("If debug: before printing mouse location")
        
        let mouseXLocation = Int(NSEvent.mouseLocation.x)
        let mouseYLocation = Int(NSEvent.mouseLocation.y)
        print("x & y", mouseXLocation, mouseYLocation)
        
        let stringInforOfScreenshotData = tempScreenshotData as String
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
       
        print("caputreRect", tempScreenshotData)
        dialogOK(question: stringInforOfScreenshotData, text: "Click OK to continue.")
        
//        if(tempScreenshotD.contains("captureRect")){
//             dialogOK(question: "writting: screenshotData contains keyword captureRect", text: "Click OK to continue.")
//        }
        if tempScreenshotData.contains("captureRect"){
            
            dialogOK(question: "screenshotData contains keyword captureRect", text: "Click OK to continue.")
            
            // get the index of ( and )
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
            
            let screenshotTotalArea = screenshotArea(width: secondCoordinationXInt, height: secondCoordinationYInt)
            //set the threshold for the screenshot area
            if( screenshotTotalArea <= Int(25)){
                screenshotCaseIndex = 0
                takeScreenshotSuccess = false
            }
            
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
            
            if(screenshotHeightInRect == 0 || screenshotWidthInRect == 0){
                screenshotCaseIndex = 0
            }
            // 1 -------2
            // |        |
            // 3 -------4
            
            
            secondCoordinationXInt = mouseEndXLocation
            secondCoordinationYInt = mouseEndYLocation
            
            // takeScreenshotSuccess = true
            
            let tempWidthValue = calculateWidth(valueOne: firstCoordinationXInt, valueTwo: secondCoordinationXInt)
            let tempHeightValue = calculateHeight(valueOne: firstCoordinationYInt, valueTwo: secondCoordinationYInt)
            
            // 1 -------2
            // |        |
            // 3 -------4
            
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
            
            // print four bounds for the screenshot
//            print(top) // width, which is x
//            print(bottom) // height, which is y
//            print(left) // screenshot width
//            print(right)   // screenshot height
            
        }
        // !tempScreenshotData.contains("captureRect")
        else{
            dialogOK(question: "no rectange", text: "Click OK to continue.")
            takeScreenshotSuccess = false
            screenshotCaseIndex = 0
        }
        
        // wait until the task is finished
        task.waitUntilExit()
        
        
        if(screenshotCaseIndex == 0){
            dialogOK(question: "screenshotCaseIndex is 0", text: "Click OK to continue.")
        }
        if(takeScreenshotSuccess == false){
            dialogOK(question: "rakeSccreenshotSuccess is false", text: "Click OK to continue.")
        }
        
        // the screenshot is invalid or the process of taking a screenshot is not finihsed
        print("screenshotCaseIndex", screenshotCaseIndex)
        
        if (screenshotCaseIndex == 0 && takeScreenshotSuccess == false){
            takeScreenshotSuccess = false
            print("the captured screenshot is not valid")
            
            dialogOK(question: "This screenshot is too small or the process of taking a screenshot is not finished.", text: "Click OK to continue.")
            // end this function
            return
        }
        else {
            takeScreenshotSuccess = true
        }
        

        // print("takeScreenshotSuccess", takeScreenshotSuccess)
        if (takeScreenshotSuccess){
            
            
            // assgin values into screenshot region struct
            let currentScreenshotReginInfor = screenshotCaptureRegion(left: left, top : top, right : right, bottom : bottom, width : width, height : height)
            
            //
            screenshotStruct.metaDataSingleRecordingTemplate["CaptureRegion"] = currentScreenshotReginInfor.screenshotRegion as! [String : Int]
            
            // get captured application names
//            print("screenshot informaiont:")
//            print(currentScreenshotReginInfor)
//            print(type(of: currentScreenshotReginInfor))
            
            let applicationNameStackHandler = softwareClassify()

            // from old algorithm
            // let visiableApplicationNameArray = applicationNameStackHandler.getOpenedRunningApplicaionNameList(imageInfor: currentScreenshotReginInfor, wholeInfor : &screenshotStruct)
            
            // from bit masking algorithm
            let visiableApplicationNameArrayFromBitMasking = applicationNameStackHandler.getOpenedRunningApplicaionNameListWithBitMasking(imageInfor: currentScreenshotReginInfor, wholeInfor: &screenshotStruct)
            
            // put captured application names into an array and saved as a global variable for future use
            tempScreenshotInformationStruct.capturedApplicationNameArray = visiableApplicationNameArrayFromBitMasking
            // print("type of visiableApplicationNameArrayFromBitMasking:" , type(of: visiableApplicationNameArrayFromBitMasking))
            print("tempScreenshotInformationStruct.capturedApplicationNameArray",tempScreenshotInformationStruct.capturedApplicationNameArray)
            // print(type(of: tempScreenshotInformationStruct.capturedApplicationNameArray))
            
            // print(visiableApplicationNameArrayFromBitMasking)
            // print("screenshot informaiton is: ")
            // print(screenshotStruct)
            
            
            
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
            print(type(of: csvContent))
            
            
            var capturedApplicationInformationDic = screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
            print(screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]])
            // dictiornary for repeating application names
            // e.g., two google chrome
            var dictionaryForRepeatApplicationNames = [String : Int]()
            
            
            // two for loops to search application name and get metdata
            for (appIndex, singleAppInfor) in capturedApplicationInformationDic.enumerated(){
                
                // print(appIndex)
                
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
                        
//                        print("original apple scripts from csv file: ")
//                        print(appleScriptForMetaDataOne)
//                        print(appleScriptForMetaDataTwo)
                        
                        //
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
                        // merge metadat into application's struct
                        // code here
                        // print(type(of: screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"]))
                        // print(screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"])
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
                    // code here
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
//            for e in 0..<elementCount{
//                let infor1 = capturedApplicationInformationDic[e]["ApplicationName"] as! String
//                let infor2 = capturedApplicationInformationDic[e]["FirstMetaData"] as! String
//                let tempStr1 = infor1 + infor2
//                let infor3 = capturedApplicationInformationDic[e]["SecondMetaData"] as! String
//                let tempStr2 = tempStr1 + infor3
//                simpleWholeInfor += tempStr2
//            }
            print(simpleWholeInfor)
            let allValuesInString = capturedApplicationInformationDic.description
            print(allValuesInString);
            // code here, adding new string value
            screenshotStruct.metaDataSingleRecordingTemplate["AppInforString"] = simpleWholeInfor
            
            
            
            // applescriptHandler.applicationMetaData(applicationNameStack: applicationNameStack)
            print("the process of takeing screenshot is finished, and the images has been saved locally.")
           
            tempScreenshotInformationStruct.dataDictionary = screenshotStruct.metaDataSingleRecordingTemplate
            print(tempScreenshotInformationStruct.dataDictionary)
            
            // code here, 3/11
            print("visiable application name stack is: ")
            print(visiableApplicationsNameArrayPublic)
            // tempScreenshotInformationStruct.dataDictionary or screenshotStruct.metaDataSingleRecordingTemplate
            var originalData = tempScreenshotInformationStruct.dataDictionary
            originalData["VisiableApplicationNames"] = visiableApplicationsNameArrayPublic
            // originalData["ApplicationInformation"]
            
            
            // print("the type of tempScreenshotInformationStruct is : ");
            // Dictionary<String, Any>
            // print(type(of: tempScreenshotInformationStruct.dataDictionary))
        
            // save this temp screenshot's informatino to the temp json file
            // tempScreenshotInformationStruct.dataDictionary
            
            let tempJsonFileHandler = tempJsonFileOperations();
            // clear the temp json file first
            // print(basicInformation.tempScreenshotJsonFilePathString)
            tempJsonFileHandler.clearTempJsonFile(FilePath: basicInformation.tempScreenshotJsonFilePathString)
            // overwrite new temp json data into the file
            // print(tempScreenshotInformationStruct.dataDictionary)
            tempJsonFileHandler.writeTempJsonData(screenshotDic: tempScreenshotInformationStruct.dataDictionary)
            
            
            if (takeScreenshotSuccess == true){
                // open the "captured view" Window
                // with macos swift nsviewcontroller, old method
//                let viewController : NSViewController = CapturedViewWiondow()
//                let subWindow = NSWindow(contentViewController: viewController)
//                let subWindowController = NSWindowController(window: subWindow)
//                subWindowController.showWindow(nil)
                
                // webvewWindow: current method, in web browser, webkit
//                let viewController1 : NSViewController = capturedViewInWeb()
//                //viewController.receivedScreenshotInfor = screenshotStruct
//                let subWindow1 = NSWindow(contentViewController: viewController1)
//                let subWindowController1 = NSWindowController(window: subWindow1)
//                subWindowController1.showWindow(nil)
                
                
                // open in the browser
                 runApplescript(applescript: openSafariScript)
            }
            else{
                // takeScreenshotSuccess is false
            }
            
            
            
            
            
            
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
    
    func getExecutableAppleScriptByReplacingName(originalString: String, applicationName : String) -> String{
        let tempString = originalString
        let executabltAppleScript = tempString.replacingOccurrences(of: "AlternativeApplicationName", with: applicationName)
        return executabltAppleScript
    }
    
    
    func getExecutableAppleScriptByReplacingRank(originalString : String, rank : String) -> String {
//        let tempString = originalString
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .ordinal
//        let ordinalFormatResult = formatter.string(from: NSNumber(value: rank))! as String
        let executableAppleScript = originalString.replacingOccurrences(of: "AlternativeRankNumber", with: rank)
        return executableAppleScript
    }

    func returnApplicationMetadata(formattedAppleScript: String) -> String{
        let applescriptResultFirstRun = runApplescript(applescript: formattedAppleScript)
        let finalResult = runApplescript(applescript: applescriptResultFirstRun)
        return finalResult
    }
    
    
    
    // taks screenshot for the whole screen, still need revise
    func wholeScreenCapture(){
        
        var screenshotStruct = screenshotInformation()
    
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd,HH-mm-ss"
        let dateString = dateFormatter.string(from: date)
        capturedScreenshotInformation.capturedScreenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        let screenshotPicName = "Screenshot-" + dateString + ".jpeg"
        capturedScreenshotInformation.capturedScreenshotPathURL = URL(string: capturedScreenshotInformation.capturedScreenshotPathString)
        
        var simpleWholeInfor = ""
        
        screenshotStruct.metaDataSingleRecordingTemplate["TimeStamp"] = dateString
        screenshotStruct.metaDataSingleRecordingTemplate["WholeScreenshotOrNot"] = false
        let screenshotPathString = basicInformation.defaultFolderPathString + "Screenshot-" + dateString + ".jpeg"
        screenshotStruct.metaDataSingleRecordingTemplate["ImagePath"] = screenshotPathString
        screenshotStruct.metaDataSingleRecordingTemplate["ScreenshotPictureName"] = screenshotPicName
        screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = [] as! [[String : Any]]
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-x")
        
        let tempScreenshotPath = capturedScreenshotInformation.capturedScreenshotPathString
        arguments.append(tempScreenshotPath)

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

        // wait until the task is finished
    
        let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
        let resultInformation = String(data: outputData, encoding: .utf8)
        
        // dialogOK(question: resultInformation!, text: "Click OK to continue.")
        
        // get the main screen paramters, width and height
        let currentMainScreen = NSScreen.main
        let rectArea = currentMainScreen!.frame
        let mainScreenHeight = Int(rectArea.size.height)
        let mainScreenWidth = Int(rectArea.size.width)
        
        let left = Int(0)
        let top = Int(0)
        let right = Int(mainScreenWidth)
        let bottom = Int(mainScreenHeight)
        
        takeScreenshotSuccess = true
        
        // assgin values into screenshot region struct
        let currentScreenshotReginInfor = screenshotCaptureRegion(left: left, top : top, right : right, bottom : bottom, width : width, height : height)
        
        //
        screenshotStruct.metaDataSingleRecordingTemplate["CaptureRegion"] = currentScreenshotReginInfor.screenshotRegion as! [String : Int]
        
        
        

        // wait until all tasks finished, including saving pic, etc
        task.waitUntilExit()

        if (takeScreenshotSuccess){
            
            // get captured application names
            print("screenshot informaiont:")
            print(currentScreenshotReginInfor)
            
            let applicationNameStackHandler = softwareClassify()

            // from bit masking algorithm
            let visiableApplicationNameArrayFromBitMasking = applicationNameStackHandler.getOpenedRunningApplicaionNameListWithBitMasking(imageInfor: currentScreenshotReginInfor, wholeInfor: &screenshotStruct)
            
            // put captured application names into an array and saved as a global variable for future use
            tempScreenshotInformationStruct.capturedApplicationNameArray = visiableApplicationNameArrayFromBitMasking
    
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

            var capturedApplicationInformationDic = screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] as! [[String : Any]]
            
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
                        //
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
                        print(appleScriptForMetaDataOne)
                        print(appleScriptForMetaDataTwo)
                        
                        let applicationMetadataResultOne = runApplescript(applescript: appleScriptForMetaDataOne)
                        let applicationMetadataResultTwo = runApplescript(applescript: appleScriptForMetaDataTwo)
                        
                        var appDictTemp = capturedApplicationInformationDic[appIndex]
                        appDictTemp["Category"] = categoryIndex
                        appDictTemp["FirstMetaData"] = applicationMetadataResultOne
                        appDictTemp["SecondMetaData"] = applicationMetadataResultTwo
                        appDictTemp["Rank"] = rankValue
                        appDictTemp["ApplicationNameWithRank"] = appName + "(" + String(describing: seenCount) + ")"
                        capturedApplicationInformationDic[appIndex] = appDictTemp
                        
                    // end of if statement (tempApplicationName == appName)
                    }
                 
                    // end of for loop for i in 0..<csvContentRow
                }
                
                // this applicaiton is not saved in the csv file, then use default string for metadata
                if (foundOrNot == false){
                    // code here
                    let seenCount = dictionaryForRepeatApplicationNames[appName]
                    let rankValue = numberToOrdinalDictionary[seenCount ?? 1]
                    var appDictTemp = capturedApplicationInformationDic[appIndex]
                    appDictTemp["Category"] = "None"
                    appDictTemp["FirstMetaData"] = "Currently, this information is empty!"
                    appDictTemp["SecondMetaData"] = "Currently, this information is empty!"
                    appDictTemp["Rank"] = rankValue
                    capturedApplicationInformationDic[appIndex] = appDictTemp
                }
                
            // end of for loop for singleAppInfor in capturedApplicationInformationDic
            }
            
            // write new data struct into screenshotStruct
            screenshotStruct.metaDataSingleRecordingTemplate["ApplicationInformation"] = capturedApplicationInformationDic
            
            
            // simpleWholeInfor
            let elementCount = capturedApplicationInformationDic.count
//            for e in 0..<elementCount{
//                let infor1 = capturedApplicationInformationDic[e]["ApplicationName"] as! String
//                let infor2 = capturedApplicationInformationDic[e]["FirstMetaData"] as! String
//                let tempStr1 = infor1 + infor2
//                let infor3 = capturedApplicationInformationDic[e]["SecondMetaData"] as! String
//                let tempStr2 = tempStr1 + infor3
//                simpleWholeInfor += tempStr2
//            }
            print(simpleWholeInfor)
            let allValuesInString = capturedApplicationInformationDic.description
            print(allValuesInString);
            // code here, adding new string value
            screenshotStruct.metaDataSingleRecordingTemplate["AppInforString"] = simpleWholeInfor
            
            
            
            // applescriptHandler.applicationMetaData(applicationNameStack: applicationNameStack)
            print("the process of takeing screenshot is finished, and the images has been saved locally.")
           
            tempScreenshotInformationStruct.dataDictionary = screenshotStruct.metaDataSingleRecordingTemplate

            let tempJsonFileHandler = tempJsonFileOperations();
            // clear the temp json file first
            // print(basicInformation.tempScreenshotJsonFilePathString)
            tempJsonFileHandler.clearTempJsonFile(FilePath: basicInformation.tempScreenshotJsonFilePathString)
            // overwrite new temp json data into the file
            // print(tempScreenshotInformationStruct.dataDictionary)
            tempJsonFileHandler.writeTempJsonData(screenshotDic: tempScreenshotInformationStruct.dataDictionary)
            
            if (takeScreenshotSuccess == true){
                // open the "captured view" Window
                // old method
//                let viewController : NSViewController = CapturedViewWiondow()
//                let subWindow = NSWindow(contentViewController: viewController)
//                let subWindowController = NSWindowController(window: subWindow)
//                subWindowController.showWindow(nil)
                
                
                // webviewWindow: current method, in web browser, webkit
//                let viewController1 : NSViewController = capturedViewInWeb()
//                //viewController.receivedScreenshotInfor = screenshotStruct
//                let subWindow1 = NSWindow(contentViewController: viewController1)
//                let subWindowController1 = NSWindowController(window: subWindow1)
//                subWindowController1.showWindow(nil)
                
                // open in the browser
                 runApplescript(applescript: openSafariScript)
                
                
            }
            else{
                // taking screenshot is not work
            }
            
            
        }
            
        else {
            print("the action of taking a screenshot failed. please repeat your action.")
        }
        // end of the wholeScreeCapture function
    }
    
    func screenshotArea(width : Int, height : Int) -> Int{
        return width * height
    }
    
    
    // func for pupping up a alert window for saving and deleting
    func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    @objc func timeDelay(){
        print("time delay function")
    }
    
    // end of class
    
}

