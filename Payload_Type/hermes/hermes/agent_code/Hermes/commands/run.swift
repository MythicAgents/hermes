//
//  run.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

var alreadyRun = false
// https://www.hackingwithswift.com/example-code/system/how-to-run-an-external-program-using-process
func runBinary(job: Job) {
    // Split executable from parameters
    var splitJobParameters = job.parameters.components(separatedBy: " ")
    let executablePath = splitJobParameters[0]
    
    // Run executable with arguments
    do {
        if alreadyRun == false {
            alreadyRun = true
            
            let task = Process()
            let outputPipe = Pipe()
            
            task.executableURL = URL(fileURLWithPath: executablePath)
            
            // Check for arguments
            if splitJobParameters.count > 1 {
                splitJobParameters.removeFirst()
                task.arguments = splitJobParameters
            }
            
            task.standardOutput = outputPipe
            task.standardError = outputPipe
            
            try task.run()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            
            job.result = toString(data: outputData)
            job.completed = true
            job.success = true
            alreadyRun = false
        }
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
        alreadyRun = false
    }
}
