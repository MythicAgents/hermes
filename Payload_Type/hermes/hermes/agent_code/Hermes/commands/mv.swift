//
//  mv.swift
//  Hermes
//
//  Created by Justin Bui on 7/28/21.
//

import Foundation

func mv(job: Job) {
    do {
        // Convert json to source and destination
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        var source = jsonParameters["source"].stringValue
        var destination = jsonParameters["destination"].stringValue
        
        // Strip out quotes if they exist, concept from Apfell agent
        if (source.prefix(1) == "\"") {
            source.removeFirst()
            source.removeLast()
        }
        if (destination.prefix(1) == "\"") {
            destination.removeFirst()
            destination.removeLast()
        }
        
        // Check if ~ to base search from user home directory
        if (source.prefix(1) == "~") {
            source = NSString(string: source).expandingTildeInPath
        }
        if (destination.prefix(1) == "~") {
            destination = NSString(string: destination).expandingTildeInPath
        }
        
        // Move file or folder
        try FileManager.default.moveItem(atPath: source, toPath: destination)
        
        job.result = "\(source) moved to \(destination)"
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
