//
//  jobs.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func listJobs(job: Job, jobList: JobList) {
    job.result = "JobID\tCmd\t\tParams\n-----\t---\t\t------\n"
    
    for iterateJob in jobList.jobs {
        if iterateJob.command != "jobs" {
            job.result  += "\(iterateJob.jobID)\t\(iterateJob.command)\t\t\(iterateJob.parameters)\n"
        }
    }
    job.completed = true
    job.success = true
}
