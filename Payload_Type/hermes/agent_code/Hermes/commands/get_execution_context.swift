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
            job.result += "__CFBundleIdentifier=\(bundleIdentifier)\n"
            if bundleIdentifier == "com.apple.Terminal" || bundleIdentifier == "com.googlecode.iterm2" {
                job.result += "Loaded within Terminal, use \"tcc_folder_check\" to see if you have access to TCC-protected folders\n"
            }
        }
    }
    if let xpcServiceName = ProcessInfo.processInfo.environment["XPC_SERVICE_NAME"]{
        if !("\(xpcServiceName)".contains("0")){
            job.result += "XPC_SERVICE_NAME=\(xpcServiceName)\n"
            job.result += "Loaded within an Application Bundle or Launch Item\n"
        }
    }
    if let packagePath = ProcessInfo.processInfo.environment["PACKAGE_PATH"]{
        if !("\(packagePath)".contains("0")){
            job.result += "PACKAGE_PATH=\(packagePath)\n"
            job.result += "Loaded within an Installer Package\n"
            
        }
    }
    
    if job.result == "" {
        job.result = "Execution context could not be determined."
    }
    job.completed = true
    job.success = true
}
