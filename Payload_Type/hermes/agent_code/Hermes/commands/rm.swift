//
//  rm.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func rm(job: Job) {
    do {
        // Convert json to path
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        var path = jsonParameters["path"].stringValue
        
        // Strip out quotes if they exist, concept from Apfell agent
        if (path.prefix(1) == "\"") {
            path.removeFirst()
            path.removeLast()
        }
        
        // Check if ~ to base search from user home directory
        if (path.prefix(1) == "~") {
            path = NSString(string: path).expandingTildeInPath
        }
        
        // Delete file
        let fileURL = URL(fileURLWithPath: path)
        try FileManager.default.removeItem(at: fileURL)
        
        let jsonPayload = JSON([
            "host": Host.current().localizedName!,
            "path": path,
        ])
        
        job.removedFiles = jsonPayload
        job.result = "\(path) was removed"
        job.completed = true
        job.success = true
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
