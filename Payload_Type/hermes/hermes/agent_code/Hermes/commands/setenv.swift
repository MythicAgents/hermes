//
//  setenv.swift
//  Hermes
//
//  Created by Justin Bui on 7/26/21.
//

import Foundation

func setEnvironmentVariable(job: Job) {
    if job.parameters.contains(" ") {
        let components = job.parameters.components(separatedBy: " ")
        setenv(components[0], components[1], 1)
        job.result = "Successfully set \(components[0])=\(components[1])"
        job.completed = true
        job.success = true
    }
    else {
        job.result = "Error: Improper command format given. Must be of format \"setenv NAME VALUE\""
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
