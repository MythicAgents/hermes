//
//  sleep.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func sleep(job: Job) {
    do {
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        agentConfig.sleep = jsonParameters["interval"].int32Value
        agentConfig.jitter = jsonParameters["jitter"].int32Value
        
        job.result = "Successfully updated agent config"
        job.completed = true
        job.success = true
    }
    catch{
        job.result = "Failed to update agent config. Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
