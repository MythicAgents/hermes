//
//  pwd.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func pwd(job: Job) {
    let fileManager = FileManager.default
    let workingDir = fileManager.currentDirectoryPath
    
    job.result = workingDir
    job.completed = true
    job.success = true
}
