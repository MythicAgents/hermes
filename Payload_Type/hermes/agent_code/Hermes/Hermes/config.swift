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
    
    // Agent components
    var sleep: Int32
    var jitter: Int32
    var killDate: String //day-month-year, ex. 01-05-1994
}

var agentConfig = AgentConfig(
    payloadUUID: "71a909a4-80a2-4b8b-9e2a-44bfb01da81d",
    encodedAESKey: "hu9mDeRH4QoXzmSFzwvRPaAxUgk1f+ke5HLZf5gSEBE=",
    
    callbackHost: "192.168.196.3",
    getRequestURI: "/index",
    postRequestURI: "/data",
    callbackPort: 80,
    userAgent: "Hermes user agent",
    hostHeader: "",
    useSSL: false,
    queryParameter: "session",
    
    sleep: 5,
    jitter: 5,
    killDate: "01-06-2022"
)
