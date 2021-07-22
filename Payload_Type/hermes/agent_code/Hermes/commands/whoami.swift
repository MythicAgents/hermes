//
//  whoami.swift
//  Hermes
//
//  Created by Justin Bui on 7/21/21.
//

import Foundation

func whoami(job: Job) {
    job.result = "\(NSUserName())"
    job.completed = true
    job.success = true
}
