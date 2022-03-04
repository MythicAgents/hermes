//
//  kill.swift
//  Hermes
//
//  Created by Justin Bui on 11/11/21.
//

import Foundation

func killProcess(job: Job) {
    let killPID = Int32(job.parameters)
    
    // Check if PID exists, then kill
    if kill(killPID!, 0) == 0 {
        kill(killPID!, SIGKILL)
        job.result = "Process with PID \(job.parameters) was killed."
        job.completed = true
        job.success = true
    }
    else {
        job.result = "Process with PID \(job.parameters) could not be found."
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
