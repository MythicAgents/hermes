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
    payloadUUID: "a556c6a0-5f2c-49f1-8722-604f297373e8",
    encodedAESKey: "9Lc0vCAnscwC9YJsdgYKSB0Fp5zH6mz2BpZqJWw+NF8=",

    callbackHost: "192.168.196.3",
    getRequestURI: "/index",
    postRequestURI: "/data",
    callbackPort: 80,
    userAgent: "Hermes user agent",
    hostHeader: "",
    useSSL: false,
    queryParameter: "q",
    httpHeaders: ["key1":"value1","key2":"value2"],

    sleep: 5,
    jitter: 5,
    killDate: "2022-05-01"
)
