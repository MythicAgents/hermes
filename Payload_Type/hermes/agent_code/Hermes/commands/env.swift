//
//  env.swift
//  Hermes
//
//  Created by Justin Bui on 7/26/21.
//

import Foundation

func getEnvironmentVariables(job: Job) {
    let environmentVariables = ProcessInfo.processInfo.environment
    
    for variable in environmentVariables {
        job.result += "\(variable.key)=\(variable.value)\n"
    }
    job.completed = true
    job.success = true
    
}
