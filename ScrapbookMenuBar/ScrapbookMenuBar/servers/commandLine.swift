//
//  commandLine.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 10/6/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//


import Foundation

func shell(_ launchPath: String, _ arguments: [String]) -> String?
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)

    return output
}

// Example usage:
// shell("ls -la")
