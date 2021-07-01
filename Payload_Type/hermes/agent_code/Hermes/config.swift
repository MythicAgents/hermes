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
    payloadUUID: "REPLACE_PAYLOAD_UUID",
    encodedAESKey: "REPLACE_ENCODED_AES_KEY",
    
    callbackHost: "REPLACE_CALLBACK_HOST",
    getRequestURI: "REPLACE_GET_REQUEST_URI",
    postRequestURI: "REPLACE_POST_REQUEST_URI",
    callbackPort: REPLACE_CALLBACK_PORT,
    userAgent: "REPLACE_USER_AGENT",
    hostHeader: "REPLACE_HOST_HEADER",
    useSSL: REPLACE_USE_SSL,
    queryParameter: "REPLACE_QUERY_PARAMETER",
    
    sleep: REPLACE_SLEEP,
    jitter: REPLACE_JITTER,
    killDate: "REPLACE_KILL_DATE"
)

//var agentConfig = AgentConfig(
//    payloadUUID: "71a909a4-80a2-4b8b-9e2a-44bfb01da81d",
//    encodedAESKey: "hu9mDeRH4QoXzmSFzwvRPaAxUgk1f+ke5HLZf5gSEBE=",
//
//    callbackHost: "192.168.196.3",
//    getRequestURI: "/index",
//    postRequestURI: "/data",
//    callbackPort: 80,
//    userAgent: "Hermes user agent",
//    hostHeader: "",
//    useSSL: false,
//    queryParameter: "session",
//
//    sleep: 5,
//    jitter: 5,
//    killDate: "2022-05-01"
//)
