//
//  tcc_folder_check.swift
//  Hermes
//
//  Created by Justin Bui on 3/2/22.
//

import Foundation

// https://github.com/cedowens/Spotlight-Enum-Kit/blob/main/TCC-Checker-Swift/Sources/TCC-Checker-Swift/main.swift#L26-L53
// https://cedowens.medium.com/spotlighting-your-tcc-access-permissions-ec6628d7a876
func tccFolderCheck(job: Job) {
    let username = NSUserName()
    let queryString = "kMDItemKind = Folder -onlyin /Users/\(username)"
    
    if let query = MDQueryCreate(kCFAllocatorDefault, queryString as CFString, nil, nil) {
        MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue))

        for i in 0..<MDQueryGetResultCount(query) {
            if let rawPtr = MDQueryGetResultAtIndex(query, i) {
                let item = Unmanaged<MDItem>.fromOpaque(rawPtr).takeUnretainedValue()
                if let path = MDItemCopyAttribute(item, kMDItemPath) as? String {
                    if path == "/Users/\(username)/Desktop" {
                        job.result += "Terminal has been granted TCC access to \(path)"
                    }
                    if path == "/Users/\(username)/Documents"{
                        job.result += "Terminal has been granted TCC access to \(path)"
                    }
                    if path == "/Users/\(username)/Downloads"{
                        job.result += "Terminal has been granted TCC access to \(path)"
                    }
                }
            }
        }
    }
    
    
    if job.result == "" {
        job.result = "Terminal has not been granted to TCC-protected folders."
    }
    job.completed = true
    job.success = true
}
