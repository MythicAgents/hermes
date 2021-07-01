//
//  cat.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func cat(job: Job) {
    do {
        let path = job.parameters
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
