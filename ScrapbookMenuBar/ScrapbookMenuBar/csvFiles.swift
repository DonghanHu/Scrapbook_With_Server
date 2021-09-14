//
//  csvFiles.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 9/7/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Foundation
import AppKit

class csvFilesOperations : NSObject {
    
    func readCSVFile(filePath : String) -> Array<Array<String>>{
        let contentsOfFilePath = Bundle.main.path(forResource: filePath, ofType: "csv") ?? ""
        if (contentsOfFilePath == ""){
            print("the content of this file is empty, the file path is: " + filePath)
        }
        var fileContents = try! String(contentsOfFile: contentsOfFilePath, encoding: .utf8)
        // remove empty rows
        fileContents = cleanRows(file: fileContents)
        let afterTransfer = csvTransfer(data: fileContents)
        // type: Array<Array<String>>
        // print(type(of: afterTransfer))
        // print(afterTransfer)
        
        return afterTransfer
    }
    
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
//      cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
//      cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
        return cleanFile
    }
    
    func csvTransfer(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            // print(row)
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    // end of the class
}
