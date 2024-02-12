//
//  unsetenv.swift
//  Hermes
//
//  Created by Justin Bui on 7/26/21.
//

import Foundation

func unsetEnvironmentVariable(job: Job) {
    unsetenv(job.parameters)
    job.result = "Unset \"\(job.parameters)\" environment variable"
    job.completed = true
    job.success = true
}
