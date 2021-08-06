//
//  jxa_import.swift
//  Hermes
//
//  Created by Justin Bui on 8/6/21.
//

import Foundation

func jxa_import(job: Job) {
    if job.uploadTotalChunks == 1 {
        jxaScript = job.uploadData
    
        job.result = "Script loaded, call functions with \"jxa_call\""
        job.completed = true
        job.success = true
    }
    else if job.uploadTotalChunks > 1 && (job.uploadChunkNumber <= job.uploadTotalChunks) {
        jxaScript += job.uploadData
    }
    else if job.uploadTotalChunks < job.uploadChunkNumber {
        jxaScript += job.uploadData

        job.result = "Script loaded, call functions with \"jxa_call\""
        job.completed = true
        job.success = true
    }
}


