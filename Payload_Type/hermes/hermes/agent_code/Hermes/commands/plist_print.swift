//
//  plist_print.swift
//  Hermes
//
//  Created by Justin Bui on 8/30/21.
//

import Foundation

func plist_print(job: Job) {
    do {
        var path = job.parameters
        
        // Strip out quotes if they exist, concept from Apfell agent
        if (path.prefix(1) == "\"") {
            path.removeFirst()
            path.removeLast()
        }
        
        // Check if ~ to base search from user home directory
        if (path.prefix(1) == "~") {
            path = NSString(string: path).expandingTildeInPath
        }
        
        // Check file type based on header
        let fileURL = URL(fileURLWithPath: path)
        let fileContents = try Data(contentsOf: fileURL)
        let headerBytes = fileContents.subdata(in: 0 ..< 1)
        let headerString = String(bytes: headerBytes, encoding: .utf8)
        
        switch headerString {
        case "<":
            let xml = FileManager.default.contents(atPath: path)
            let plist = try PropertyListSerialization.propertyList(from: xml!, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
            let jsonData = try JSONSerialization.data(withJSONObject: plist)

            job.result = (jsonData.prettyPrintedJSONString ?? "Failed to unwrap plist data.") as String
            job.completed = true
            job.success = true
        case "{":
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            
            job.result = (jsonData.prettyPrintedJSONString ?? "Failed to unrwap plist data.") as String
            job.completed = true
            job.success = true
        case "b":
            let binary = FileManager.default.contents(atPath: path)
            let plist = try PropertyListSerialization.propertyList(from: binary!, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
            let jsonData = try JSONSerialization.data(withJSONObject: plist)
            
            job.result = (jsonData.prettyPrintedJSONString ?? "Failed to unwrap plist data.") as String
            job.completed = true
            job.success = true
        default:
            job.result = "Error: Couldn't determine plist format"
            job.completed = true
            job.success = false
            job.status = "error"
        }
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
