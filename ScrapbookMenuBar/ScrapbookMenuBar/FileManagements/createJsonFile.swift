//
//  createJsonFile.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 8/30/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation

import Foundation
class jsonFile: NSObject {
    
    
    func createJson(filepath: URL) {
        let documentsDirectoryPath = filepath
        print(filepath)
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("Scrapbook.json")
        // print("json file path is: ", jsonFilePath)
        
        // assign global values
        basicInformation.jsonFilePathURL = jsonFilePath
        print(basicInformation.jsonFilePathURL)
        print(type(of: basicInformation.jsonFilePathURL))
        print("jsonfilepath in URL is: ", jsonFilePath.absoluteString)
        basicInformation.jsonFilePathString = jsonFilePath.absoluteString
        
        
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if !fileManager.fileExists(atPath: (jsonFilePath.absoluteString), isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath.absoluteString), contents: nil, attributes: nil)
            if created {
                
                print("Json file created successfully!")
                writeInitialData(Filepath: (jsonFilePath.absoluteString))
                
            } else {
                print("Couldn't create json file for some reason.")
            }
        } else {
            // print("json file path:", jsonFilePath)
            print("Json file is already existed!")
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
    
    // function to append single recording data to the existed array in json file
    func addSingleRecordingMetaData(){
        
    }
    
    // end of jsonFile class
}
