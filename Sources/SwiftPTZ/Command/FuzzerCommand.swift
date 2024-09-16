//
//  FuzzerCommand.swift
//
//
//  Created by syan on 12/09/2024.
//

import Foundation
import ArgumentParser

struct FuzzerCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "fuzzer")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    private var firstColLength = 23
    private var totalLength = 186

    mutating func run(camera: Camera) throws {
        camera.logLevel = .error
        try camera.sendRequest(PTZRequestSetAutoFocus(enabled: .off))
        Thread.sleep(forTimeInterval: 2)
        
        try fuzz(camera: camera)
        speak("Done")
        print("-----------------------")
        print("First column length:", firstColLength)
        print("Table row length:", totalLength)
    }
    
    private mutating func fuzz(camera: Camera) throws {
        // here are the possible commands to be found. commands starting by 0x usually are getters, commands starting by 4x are their corresponding setters
        let ranges: [(category: UInt8, registers: Range<UInt8>, arguments: Range<UInt16>)] = [
            (0x01, 0x00..<0x80, 0..<0),         // states
            (0x02, 0x00..<0x80, 0..<0),         // states
            (0x03, 0x00..<0x80, 0..<0),         // states
            // (0x04, 0x00..<0x80, 0..<0x4000), // - not executed: syntax error
            // (0x05, 0x00..<0x80, 0..<0x100),  // - not executed: command not defined
            (0x06, 0x00..<0x80, 0..<0),         // only hello here
            // (0x07, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x08, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x09, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0A, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0B, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0C, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0D, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0E, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x0F, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error

            (0x41, 0..<0,       0..<0),         // corresponding states setters, let's avoid playing with them randomly
            (0x42, 0..<0,       0..<0),         // corresponding states setters, let's avoid playing with them randomly
            (0x43, 0..<0,       0..<0),         // corresponding states setters, let's avoid playing with them randomly
            // (0x44, 0x00..<0x80, 0..<0x4000), // - not executed: syntax error
            (0x45, 0x00..<0x80, 0..<0x4000),    // one-shot actions (moving, reset, measure white balance, ...)
            // (0x46, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x47, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x48, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x49, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4A, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4B, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4C, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4D, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4E, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
            // (0x4F, 0x00..<0x80, 0..<0x100),  // - not executed: syntax error
        ]
        
        for range in ranges {
            guard !range.registers.isEmpty else { continue }
            print(String(repeating: "-", count: totalLength))

            for register in range.registers {
                // run the command without any argument first
                try {
                    let req = PTZUnknownRequest(commandBytes: [range.category, register], arg: nil)
                    let reply = try camera.sendRequest(req)
                    printResult(category: range.category, register: register, args: nil, reply: reply)
                }()
                
                // try the given range of arguments, group the results by type of reply to reduce the amount of information printed
                var replies: [(first: UInt16, last: UInt16, reply: PTZReply, replyBytes: Bytes)] = []
                for arg: UInt16 in range.arguments {
                    let req = PTZUnknownRequest(commandBytes: [range.category, register], arg: arg)
                    let (replyBytes, reply) = try camera.sendRequest2(req)
                    if (reply as? PTZReplyNotExecuted)?.error == .commandNotDefined { break }

                    // this command has a new kind of reply, let's create a new group
                    if replyBytes != replies.last?.replyBytes {
                        replies.append((arg, arg, reply, replyBytes))
                    }
                    
                    // let's move the dial on the last possible argument to receive this specific reply
                    replies[replies.count - 1].last = arg
                    
                    // we've had a lot of Syntax Error replies and are above any possibility to discover new valid args, let's stop there
                    if let current = replies.last, (current.reply as? PTZReplyNotExecuted)?.error == .syntaxError, current.first > 0x100, current.last - current.first > 0x100 {
                        break
                    }
                }
                
                // if we found at least one range of arguments that create a valid command, let's ignore all ranges that resulted in syntax error
                if replies.filter({ $0.reply is PTZReplyExecuted }).count > 0 {
                    replies.removeAll(where: { ($0.reply as? PTZReplyNotExecuted)?.error == .syntaxError })
                }
                
                // print all argument ranges that we found
                for reply in replies {
                    printResult(category: range.category, register: register, args: reply.first...reply.last, reply: reply.reply)
                }
            }
        }
    }
    
    private mutating func printResult(category: UInt8, register: UInt8, args: ClosedRange<UInt16>?, reply: any PTZReply) {
        guard !(reply is PTZReplyFail) else { return }
        guard (reply as? PTZReplyNotExecuted)?.error != .commandNotDefined else { return }
        if let args, args.isEmpty { return }

        let reqKnown = (!(reply is PTZReplyUnknown) && !(reply is PTZReplyNotExecuted)) ? "X" : " "
        
        var reqString = ""
        if let args {
            let bytes1 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: args.first!).bytes.dropFirst())
            let bytes2 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: args.last!).bytes.dropFirst())
            reqString = "8x " + bytes1.stringRepresentation(condensedWith: bytes2)
        }
        else {
            reqString = "8x " + Array(PTZUnknownRequest(commandBytes: [category, register], arg: nil).bytes.dropFirst()).stringRepresentation
        }
        
        firstColLength = max(firstColLength, reqString.count)
        reqString = reqString.padding(toLength: firstColLength, withPad: " ", startingAt: 0)
        
        let string = "\(reqString) | \(reqKnown) | \(reply)"
        totalLength = max(totalLength, string.count)
        print(string)
    }
}
