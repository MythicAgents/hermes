//
//  cat.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func cat(job: Job) {
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
        
        let fileContent = try Data(contentsOf: URL(fileURLWithPath: path))
        job.result = toString(data: fileContent)
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
