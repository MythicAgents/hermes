//
//  kill.swift
//  Hermes
//
//  Created by Justin Bui on 11/11/21.
//

import Foundation

func killProcess(job: Job) {
    let killPID = Int32(job.parameters)
    
    kill(killPID!, SIGKILL)
    
    job.result = "Process with PID \(job.parameters) was killed."
    job.completed = true
    job.success = true
}
