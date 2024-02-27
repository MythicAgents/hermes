//
//  fda_check.swift
//  Hermes
//
//  Created by Justin Bui on 7/22/21.
//

import Foundation

func fullDiskAccessCheck(job: Job) {
    do {
        // Convert json to technique
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        let technique = jsonParameters["technique"].stringValue
        
        if technique == "file handle" {
            var path = "~/Library/Application Support/com.apple.TCC/TCC.db"
            path = NSString(string: path).expandingTildeInPath
            _ = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Set to true for future ls calls, will allow to read extended attributes
            tccFullDiskAccess = true
            job.result = "\"Full Disk Access\" is enabled!"
            job.completed = true
            job.success = true
        }
        else if technique == "mdquery" {
            var pathFound = false
            let queryString = "kMDItemDisplayName = *TCC.db"
            if let query = MDQueryCreate(kCFAllocatorDefault, queryString as CFString, nil, nil) {
                MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))
                for i in 0..<MDQueryGetResultCount(query) {
                    if let rawPtr = MDQueryGetResultAtIndex(query, i) {
                        let item = Unmanaged<MDItem>.fromOpaque(rawPtr).takeUnretainedValue()
                        if let path = MDItemCopyAttribute(item, kMDItemPath) as? String {
                            if path.hasSuffix("/Library/Application Support/com.apple.TCC/TCC.db"){
                                pathFound = true
                            }
                        }
                    }
                }
                if pathFound {
                    // Set to true for future ls calls, will allow to read extended attributes
                    tccFullDiskAccess = true 
                    job.result = "\"Full Disk Access\" is enabled!"
                    job.completed = true
                    job.success = true
                }
                else {
                    job.result = "Error: \"Full Disk Access\" has not been granted"
                    job.completed = true
                    job.success = false
                    job.status = "error"
                }
            }
        }
    }
    catch {
        job.result = "Error: \"Full Disk Access\" has not been granted"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
