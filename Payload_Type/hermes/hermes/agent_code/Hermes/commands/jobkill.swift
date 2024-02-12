//
//  jobkill.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func jobKill(job: Job, jobList: JobList) {
    let killJobID = Int(job.parameters)
    
    for (index, iterateJob) in jobList.jobs.enumerated() {
        if iterateJob.jobID == killJobID {
            iterateJob.thread?.cancel()
            jobList.jobs.remove(at: index)
        }
    }
    
    job.result = "Thread for JobID \(job.parameters) was killed."
    job.completed = true
    job.success = true
}
