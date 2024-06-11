//
//  MoveCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct MoveCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "move")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String = "/dev/cu.usbserial-1110"
    
    func run() throws {
        do {
            let serial = try Serial(tag: "Rx", deviceName: serialDevice)
            serial.sendBytes(PTZRequestGetPosition().bytes)
            let bootReplies = try runSequence(bootSequence(), serial: serial)
            let reply = try runRequest(PTZRequestSetInvertMode(inverted: true), serial: serial)
            serial.stop()
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func runRequest(_ request: PTZRequest, serial: Serial) throws -> PTZReplyParsed {
        print("Running command", type(of: request))
        serial.sendBytes(request.bytes)
        print("> wrote \(request.bytes.count) bytes:", request.bytes.stringRepresentation)
        
        print("Reading reply")
        var replyReceived = false
        var replyBytes = [UInt8]()
        while !replyReceived {
            Thread.sleep(forTimeInterval: 0.1)
            let byte = serial.readByte()
            if byte == 0 && replyBytes.isEmpty {
                continue
            }

            replyBytes.append(byte)
            print(">", byte.stringRepresentation)
            
            let reply = PTZReply(bytes: replyBytes)
            guard reply.validLength else { continue }
            
            replyBytes = []
            
            print("> valid length, parsing...")
            if let parsed = reply.parsed {
                print(">", parsed)
                if parsed != .ack {
                    replyReceived = true
                    return parsed
                }
            }
            else {
                print("> couldn't parse:", replyBytes.stringRepresentation)
            }
        }
    }
    
    func runSequence(_ requests: [PTZRequest], serial: Serial) throws -> [PTZReplyParsed] {
        return try requests.map { try runRequest($0, serial: serial) }
    }
}
