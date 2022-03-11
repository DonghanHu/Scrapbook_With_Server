//
//  createTestFile.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 2/23/22.
//  Copyright © 2022 Donghan Hu. All rights reserved.
//

import Foundation

class createTestFile : NSObject{
    func creaetTestJsonFile(filepath: URL) {
        
        let documentsDirectoryPath = filepath
        print(filepath)
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("TestFile.txt")
        
        // assign global values
        basicInformation.testFilePathURL = jsonFilePath
        basicInformation.testFilePathString = jsonFilePath.absoluteString
        
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (jsonFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("test file created successfully!")
                
            } else {
                print("Couldn't create test file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("test file is already existed!")
        }
        
        //return jsonFilePath
    }
    
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
}
