//
//  createTestFile.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 2/23/22.
//  Copyright © 2022 Donghan Hu. All rights reserved.
//

import Foundation

class createTestFile : NSObject{
    func tempJson(filepath: URL) {
        
        let documentsDirectoryPath = filepath
        print(filepath)
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("tempScreenshotData.json")
        
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
}
