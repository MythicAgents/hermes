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
                    if path == "/Users/\(username)/Desktop" && !tccDesktop {
                        // Set to true for future ls calls, will allow to read extended attributes
                        tccDesktop = true
                        job.result += "This app has been granted TCC access to \(path)\n"
                    }
                    if path == "/Users/\(username)/Documents" && !tccDocuments {
                        // Set to true for future ls calls, will allow to read extended attributes
                        tccDocuments = true
                        job.result += "This app has been granted TCC access to \(path)\n"
                    }
                    if path == "/Users/\(username)/Downloads" && !tccDownloads {
                        // Set to true for future ls calls, will allow to read extended attributes
                        tccDownloads = true
                        job.result += "This app has been granted TCC access to \(path)\n"
                    }
                }
            }
        }
    }
    
    if job.result == "" {
        job.result = "Terminal has not been granted access to TCC-protected folders."
    }
    job.completed = true
    job.success = true
}
