//
//  accessibility_check.swift
//  Hermes
//
//  Created by Justin Bui on 4/27/22.
//

import Foundation

func accessibilityCheck(job: Job) {
    if AXIsProcessTrusted() {
        job.result = "\"Accessibility\" is enabled!"
        job.completed = true
        job.success = true
    }
    else {
        job.result = "Error: \"Accessibility\" has not been granted"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
