//
//  hostname.swift
//  Hermes
//
//  Created by Justin Bui on 8/6/21.
//

import Foundation

func hostname(job: Job) {
    let localizedName = Host.current().localizedName
    let names = Host.current().names
    job.result += "NSHost Localized Name: \(localizedName!)\n"
    job.result += "NSHost Names: "
    for name in names {
        job.result += name + " "
    }
    job.result += "\n\n"
    
    let processInfo = ProcessInfo.processInfo.hostName
    job.result += "NSProcessInfo Hostname: \(processInfo)\n\n"
    
    
    let fileManager = FileManager.default
    let plistPath = "/Library/Preferences/SystemConfiguration/com.apple.smb.server.plist"
    if (fileManager.fileExists(atPath: plistPath)) {
        let dict = NSDictionary(contentsOfFile: plistPath)!
        job.result += "Local Kerberos Realm: \(dict["LocalKerberosRealm"] ?? "N/A")\n"
        job.result += "NETBIOS Name: \(dict["NetBIOSName"]  ?? "N/A")\n"
        job.result += "Server Description: \(dict["ServerDescription"]  ?? "N/A")\n"
    }
    
    job.completed = true
    job.success = true
}
