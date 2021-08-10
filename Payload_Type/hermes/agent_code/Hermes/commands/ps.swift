//
//  ps.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation
import AppKit



// https://stackoverflow.com/questions/3018054/retrieve-names-of-running-processes
// https://gist.github.com/kainjow/0e7650cc797a52261e0f4ba851477c2f
// TODO: switch to this https://github.com/rodionovd/RDProcess to get everything poseidon does
func ps(job: Job) {
    // Make syscalls to get KINFO_PROC struct
    var name : [Int32] = [ CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 ]
    var length = size_t()
    sysctl(&name, UInt32(name.count), nil, &length, nil, 0)
    let count = length / MemoryLayout<kinfo_proc>.size
    var procList = Array(repeating: kinfo_proc(), count: count)
    let result = sysctl(&name, UInt32(name.count), &procList, &length, nil, 0)
    assert(result == 0, "sysctl failed")
    
    // Loop through all processes
    var jsonProcesses = [JSON]()
    for proc in procList {
       
        // Get PID
        let pid = proc.kp_proc.p_pid
        
        // Attempt to get true PPID, if it fails, return ppid from kernel structure
        var ppid = truePPID(Int(pid))
        if pid == ppid {
            ppid = proc.kp_proc.p_oppid  // this always returns process 0 which is kernel_task
        }
        
        // Get process name (this truncates ...)
        var bytesComm = proc.kp_proc.p_comm
        let processName = withUnsafePointer(to: &bytesComm) { ptr -> String in
            return String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        
        // Allocate a buffer to store the name
        let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
        defer {
            nameBuffer.deallocate()
        }
        
        // Get process name 2 (this doesn't always return a process name ...), use the truncated processName if this doesn't return
        let nameLength = proc_name(pid, nameBuffer, UInt32(MAXPATHLEN))
        var processName2 = ""
        if nameLength > 0 {
            processName2 = String(cString: nameBuffer)
        }
        else
        {
            processName2 = processName
        }
        
        // Get process full path
            let pathBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
            defer {
                pathBuffer.deallocate()
            }
            let pathLength = proc_pidpath(pid, pathBuffer, UInt32(MAXPATHLEN))
            var processPath = ""
            if pathLength > 0 {
                processPath = String(cString: pathBuffer)
            }
        
        // Convert uid to username
        let p = getpwuid(proc.kp_eproc.e_ucred.cr_uid)!
        let username = String(cString: p.pointee.pw_name)
        
        // Check running application process architecture
        let workspace = NSWorkspace.shared
        let applications = workspace.runningApplications
        let arch = applications[0].executableArchitecture
        var machoArch = "Unknown Architecture"
        if (arch == NSBundleExecutableArchitectureX86_64)
        {
            machoArch = "x64 Intel"
        }
        
        // Filter out if kernel struct returns process with no name
        if !processName2.isEmpty{
            let jsonPayload = JSON([
                "process_id": pid,
                "architecture": machoArch,
                "name": processName2,
                "user": username,
                "bin_path": processPath,
                "parent_process_id": ppid,
                ])
            jsonProcesses.append(jsonPayload)
        }
    }
    
    job.processes = jsonProcesses
    job.result = jsonProcesses.description
    job.completed = true
    job.success = true
}
