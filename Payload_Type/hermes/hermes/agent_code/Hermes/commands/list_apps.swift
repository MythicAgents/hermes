//
//  list_apps.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation
import AppKit

func listApplications(job: Job) {
    let workspace = NSWorkspace.shared
    let applications = workspace.runningApplications

    var jsonApplications = [JSON]()

    for app in applications {
        let arch = app.executableArchitecture

        // Parse architecture
        var machoArch: String
        switch arch {
        case NSBundleExecutableArchitectureARM64:
            machoArch = "x64 ARM"
        case NSBundleExecutableArchitectureI386:
            machoArch = "x86 Intel"
        case NSBundleExecutableArchitectureX86_64:
            machoArch = "x64 Intel"
        case NSBundleExecutableArchitecturePPC:
            machoArch = "x86 PowerPC"
        case NSBundleExecutableArchitecturePPC64:
            machoArch = "x64 PowerPC"
        default:
            machoArch = "Unknown Architecture"
        }

        let jsonPayload = JSON([
            "frontMost": app.isActive,
            "hidden": app.isHidden,
            "bundle": app.bundleIdentifier ?? "could not determine bundle identifier",
            "bundleURL": app.bundleURL?.path,
            "bin_path": app.executableURL?.path,
            "process_id": app.processIdentifier,
            "name": app.localizedName ?? "could not get local name",
            "architecture": machoArch,
            ])
        jsonApplications.append(jsonPayload)
    }

    job.processes = jsonApplications
    job.result = jsonApplications.description
    job.completed = true
    job.success = true
}
