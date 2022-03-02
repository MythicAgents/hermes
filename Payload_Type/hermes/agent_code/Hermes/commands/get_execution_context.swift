//
//  get_execution_context.swift
//  Hermes
//
//  Created by Justin Bui on 3/2/22.
//

import Foundation

// https://cedowens.medium.com/give-me-some-macos-context-c13aecbd4c5b
// https://github.com/cedowens/SwiftBelt/blob/master/Sources/SwiftBelt/main.swift#L200-L225
func getExecutionContext(job: Job) {
    if let bundleIdentifier = ProcessInfo.processInfo.environment["__CFBundleIdentifier"]{
        if !("\(bundleIdentifier)".contains("0")){
            job.result += "Current process context: \(bundleIdentifier)"
        }
    }
    if let xpcServiceName = ProcessInfo.processInfo.environment["XPC_SERVICE_NAME"]{
        if !("\(xpcServiceName)".contains("0")){
            job.result += "Current process context: \(xpcServiceName)"
        }
    }
    if let packagePath = ProcessInfo.processInfo.environment["PACKAGE_PATH"]{
        if !("\(packagePath)".contains("0")){
            job.result += "Current process context: \(packagePath)"
            
        }
    }
    
    if job.result == "" {
        job.result = "Execution context could not be determined."
    }
    job.completed = true
    job.success = true
}
