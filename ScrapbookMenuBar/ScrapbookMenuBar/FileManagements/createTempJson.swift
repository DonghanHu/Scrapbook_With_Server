//
//  createTempJson.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 11/22/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation

class tempJsonFileOperations : NSObject {
    
    func tempJson(filepath: URL) {
        
        let documentsDirectoryPath = filepath
        print(filepath)
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("tempScreenshotData.json")
        
        // assign global values
        basicInformation.tempScreenshotJsonFilePathURL = jsonFilePath
        basicInformation.tempScreenshotJsonFilePathString = jsonFilePath.absoluteString
        
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (jsonFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("Temp Json file created successfully!")
                writeInitialData(Filepath: (jsonFilePath.absoluteString))
                
            } else {
                print("Couldn't create json file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("Temp Json file is already existed!")
        }
        
        //return jsonFilePath
    }
    
    // write inital data into json file
    func writeInitialData(Filepath : String){
        
        // current this json file is empty
        let emptyArray =  [Any]()
        // put an empty array into the created json file
        
        let jsonData = try! JSONSerialization.data(withJSONObject: emptyArray, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        if FileManager.default.fileExists(atPath: Filepath){
            if let fileHandle = FileHandle(forWritingAtPath: Filepath){
                fileHandle.write(jsonData)
                fileHandle.closeFile()
            }
            else {
                let nsError = NSError()
                let errorMessage = nsError.localizedDescription
                print("Can't open fileHandle" + errorMessage)
            }
        }
    }
    
    // write temp screenshot's data into this temp json file
    func writeTempJsonData(screenshotDic : Dictionary<String, Any>){
        let path = basicInformation.tempScreenshotJsonFilePathString
        print(path)
        
            do {
                let originalData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                do{
                    var rawJsonData = try JSONSerialization.jsonObject(with : originalData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String, Any>>
                    rawJsonData?.append(screenshotDic)
                    let jsonData = try JSONSerialization.data(withJSONObject: rawJsonData, options: [])
                    if let file = FileHandle(forWritingAtPath : basicInformation.tempScreenshotJsonFilePathString) {
                        file.write(jsonData)
                        file.closeFile()
                    }
                    
                }
                catch{
                     print("Unexpected error 1 at write tempJsonData: \(error).")
                }
              } catch {
                    print("Unexpected error 2 at write tempJsonData: \(error).")
                   // handle error
              }
    }
    
    // overwrite current temp json file
    func clearTempJsonFile(FilePath : String){
        print(FilePath)
        
        // clear the previous information first
        let text = ""
        try! text.write(toFile: FilePath, atomically: false, encoding: String.Encoding.utf8)
        
        let initArray = [Any]();
        
        let arrayData = try! JSONSerialization.data(withJSONObject: initArray, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        
        // overwrite a new empty new array
        if FileManager.default.fileExists(atPath: FilePath){
            if let fileHandle = FileHandle(forWritingAtPath: FilePath){
            
                fileHandle.write(arrayData)
                fileHandle.closeFile()
            }
            else {
                let nsError = NSError()
                let errorMessage = nsError.localizedDescription
                print("Can't open fileHandle" + errorMessage)
            }
        }
    }
    
    // end of the class

}
