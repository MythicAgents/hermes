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
        
        var isDir : ObjCBool = false
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
            // Delete file/folder
            let fileURL = URL(fileURLWithPath: path)
            try FileManager.default.removeItem(at: fileURL)
            
            let jsonPayload = JSON([
                "host": Host.current().localizedName!,
                "path": fileURL.path,
            ])
            job.removedFiles.append(jsonPayload)
            job.result = "\(path) was removed"
            job.completed = true
            job.success = true
        }
        else {
            job.result = "Folder/file does not exist"
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
