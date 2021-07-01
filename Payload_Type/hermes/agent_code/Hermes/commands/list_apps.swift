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
        var machoArch = ""
        if (arch == NSBundleExecutableArchitectureI386)
        {
            machoArch = "x86 Intel"
        }
        else if (arch == NSBundleExecutableArchitectureX86_64)
        {
            machoArch = "x64 Intel"
        }
        else if (arch == NSBundleExecutableArchitecturePPC)
        {
            machoArch = "x86 PowerPC"
        }
        else if (arch == NSBundleExecutableArchitecturePPC64)
        {
            machoArch = "x64 PowerPC"
        }
        else
        {
            machoArch = "Unknown architecture"
        }

        let jsonPayload = JSON([
            "frontMost": app.isActive,
            "hidden": app.isHidden,
            "bundle": app.bundleIdentifier,
            "bundleURL": app.bundleURL!.path,
            "bin_path": app.executableURL!.path,
            "process_id": app.processIdentifier,
            "name": app.localizedName ?? "Could not get local name",
            "architecture": machoArch,
            ])
        jsonApplications.append(jsonPayload)
    }

    job.processes = jsonApplications
    job.result = jsonApplications.description
    job.completed = true
    job.success = true
}
