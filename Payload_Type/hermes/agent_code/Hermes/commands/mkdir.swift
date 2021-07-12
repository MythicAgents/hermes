//
//  mkdir.swift
//  Hermes
//
//  Created by Justin Bui on 7/12/21.
//

import Foundation

func makeDirectory(job: Job) {
    do {
        let fileManager = FileManager.default
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
        
        var isDir : ObjCBool = false
        if !fileManager.fileExists(atPath: path, isDirectory:&isDir) {
            // Create folder
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            
            job.result = "\(path) directory was created"
            job.completed = true
            job.success = true
        }
        else {
            job.result = "Folder/file already exist"
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
