//
//  cd.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func cd(job: Job) {
    let fileManager = FileManager.default
    var path = job.parameters
    
    // Check if ~ to base search from user home directory
    if (path.prefix(1) == "~") {
        path = NSString(string: path).expandingTildeInPath
    }
    
    if (job.parameters == "..") {
        if fileManager.changeCurrentDirectoryPath("../") {
            job.result = "Changed working directory to \(fileManager.currentDirectoryPath)"
            job.completed = true
            job.success = true
        }
        else {
            job.result = "Could not change directory to \(path)"
            job.completed = true
            job.success = false
            job.status = "error"
        }
    }
    else if fileManager.fileExists(atPath: path) {
        if fileManager.changeCurrentDirectoryPath(path) {
            job.result = "Changed working directory to \(fileManager.currentDirectoryPath)"
            job.completed = true
            job.success = true
        }
        else {
            job.result = "Could not change directory to \(path)"
            job.completed = true
            job.success = false
            job.status = "error"
        }
    }
    else {
        job.result = "No such directory"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
