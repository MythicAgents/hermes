//
//  fda_check.swift
//  Hermes
//
//  Created by Justin Bui on 7/22/21.
//

import Foundation

func fullDiskAccessCheck(job: Job) {
    do {
        var path = "~/Library/Application Support/com.apple.TCC/TCC.db"
        path = NSString(string: path).expandingTildeInPath
        _ = try Data(contentsOf: URL(fileURLWithPath: path))
        
        // Set to true for future ls calls, will allow to read extended attributes
        tccFullDiskAccess = true
        job.result = "\"Full Disk Access\" is enabled!"
        job.completed = true
        job.success = true
    }
    catch {
        job.result = "Error: \"Full Disk Access\" has not been granted"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
