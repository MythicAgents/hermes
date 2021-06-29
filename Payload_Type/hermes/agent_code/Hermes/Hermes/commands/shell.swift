//
//  shell.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func shell(job: Job) {
    // Run executable with arguments
    do {
        let task = Process()
        let outputPipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", job.parameters]
        task.standardOutput = outputPipe
        
        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        job.result = toString(data: outputData)
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
