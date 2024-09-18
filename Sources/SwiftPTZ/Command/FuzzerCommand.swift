//
//  FuzzerCommand.swift
//
//
//  Created by syan on 12/09/2024.
//

import Foundation
import ArgumentParser

// Usually takes about 5min to run on an Eagle Eye IV
struct FuzzerCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "fuzzer")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    private var firstColLength = 25
    private var totalLength = 186

    mutating func run(camera: Camera) throws {
        camera.logLevel = .error

        Thread.sleep(forTimeInterval: 2)
        
        let d = Date()
        try fuzz(camera: camera, initialState: {
            try camera.sendRequest(PTZRequestSetPosition(pan: .mid, tilt: .mid, zoom: .min))
            try camera.sendRequest(PTZRequestSetAutoExposure(enabled: .off))
            try camera.sendRequest(PTZRequestSetAutoFocus(enabled: .off))
        })
        speak("Done")

        printCategoryName("Stats")
        print("Duration:", Int(Date().timeIntervalSince(d)), "seconds")
        print("First column width:", firstColLength, "chars")
        print("Table row length:", totalLength, "chars")
    }
    
    private mutating func fuzz(camera: Camera, initialState: () throws -> ()) throws {
#warning("TODO: 82 41 70 -> executed but no ACK ?!")

        // here are the possible commands to be found. commands starting by 0x usually are getters, commands starting by 4x are their corresponding setters
        let categories: [FuzzerCategory] = [
            .init(0x01, "Getters"),
            .init(0x02, "Getters"),
            .init(0x03, "Getters"),
            // .init(0x04, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x05, args: true, "Unknown"),                  // - not executed: command not defined
            .init(0x06, "Hello"),
            // .init(0x07, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x08, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x09, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0A, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0B, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0C, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0D, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0E, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x0F, args: true, "Unknown"),                  // - not executed: syntax error

            // .init(0x41, args: true, restore: true, "Setters"),   // let's avoid playing with them randomly (power off, video output, etc)
            .init(0x42, args: true, restore: true, "Setters"),      // should be safe to play with them
            .init(0x43, args: true, restore: true, "Setters"),      // should be safe to play with them
            // .init(0x44, args: true, "Unknown"),                  // - not executed: syntax error
            .init(0x45, args: true, "Actions"),                     //
            // .init(0x46, args: true, "Unknown"),                  // - not executed: command not defined
            // .init(0x47, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x48, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x49, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4A, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4B, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4C, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4D, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4E, args: true, "Unknown"),                  // - not executed: syntax error
            // .init(0x4F, args: true, "Unknown"),                  // - not executed: syntax error
        ]
        
        for category in categories {
            guard !category.registers.isEmpty else { continue }

            printCategoryName(category.name)
            try initialState()

            for register in category.registers {
                // before playing with some setters, let's make sure we can reset them afterwards
                var restoreBlock: () -> () = {}
                restore: if category.restore {
                    let cmd = [category.category, register].stringRepresentation
                    let reply = try camera.sendRequest(PTZUnknownRequest(commandBytes: [category.category - 0x40, register], arg: nil))
                    guard let replyBytes = (reply as? PTZReplyUnknown)?.bytes else { break restore }
                    guard replyBytes.count > 2, replyBytes[1] == category.category, replyBytes[2] == register else { fatalError("Unexpected current value for \(cmd), got \(reply)") }

                    restoreBlock = {
                        _ = try? camera.sendRequest(PTZUnknownRequest(commandBytes: Array(replyBytes.dropFirst()), arg: nil))
                    }
                }
                defer { restoreBlock() }
                
                // run the command without any argument first
                try {
                    let req = PTZUnknownRequest(commandBytes: [category.category, register], arg: nil)
                    let reply = try camera.sendRequest(req)
                    printResult(category: category.category, register: register, args: nil, reply: reply, stoppedEarly: false)
                }()
                
                // try the given range of arguments, group the results by type of reply to reduce the amount of information printed
                guard category.testArgs else { continue }
                var replies: [FuzzerResult] = []
                for arg: UInt16 in 0..<0x4000 {
                    if category.category == 0x43 {
                        // moving pan, tilt, zoom and focus sometimes replies with Mode condition error when going too
                        // fast, let's make this section a wee bit slower to prevent those intermittent errors
                        usleep(5_000)
                    }

                    let req = PTZUnknownRequest(commandBytes: [category.category, register], arg: arg)
                    let (replyBytes, reply) = try camera.sendRequest2(req)
                    if (reply as? PTZReplyNotExecuted)?.error == .commandNotDefined { break }

                    // this command has a new kind of reply, let's create a new group
                    if replyBytes != replies.last?.bytes {
                        replies.append(.init(reply: reply, bytes: replyBytes, firstArg: arg, lastArg: arg))
                    }
                    
                    // let's move the dial on the last possible argument to receive this specific reply
                    replies[replies.count - 1].lastArg = arg
                    
                    // getting an error (intermittent or final)
                    if (replies.last!.reply is PTZReplyFail) || (replies.last!.reply is PTZReplyNotExecuted) {
                        // if this is the only reply we got and we already searched a while: let's stop
                        if replies.count == 1, arg >= category.maxArgIfNothingFound {
                            replies[replies.count - 1].stoppedEarly = true
                            break
                        }
                        
                        // if we've already found something else and have gotten this error for a while now: let's stop
                        if replies.count > 1, replies.last!.argRange > 0x20 {
                            replies[replies.count - 1].stoppedEarly = true
                            break
                        }
                    }
                }
                
                // if we found at least one range of arguments that create a valid or almost valid command, let's ignore all ranges that resulted in worse results
                if let maxLevel = replies.map(\.validityLevel).max() {
                    replies.removeAll(where: { $0.validityLevel < maxLevel })
                }
                
                // print all argument ranges that we found
                for reply in replies {
                    printResult(category: category.category, register: register, args: reply.firstArg...reply.lastArg, reply: reply.reply, stoppedEarly: reply.stoppedEarly)
                }
            }
        }
    }
    
    mutating func printCategoryName(_ name: String) {
        print("")
        print("")
        print(name)
        print(String(repeating: "-", count: totalLength))
    }
    
    private mutating func printResult(category: UInt8, register: UInt8, args: ClosedRange<UInt16>?, reply: any PTZReply, stoppedEarly: Bool) {
        guard !(reply is PTZReplyFail) else { return }
        guard (reply as? PTZReplyNotExecuted)?.error != .commandNotDefined else { return }
        if let args, args.isEmpty { return }

        let reqKnown = (!(reply is PTZReplyUnknown) && !(reply is PTZReplyNotExecuted)) ? "X" : " "
        
        var reqString = ""
        if let args {
            let bytes1 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: args.first!).bytes.dropFirst())
            let bytes2 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: args.last!).bytes.dropFirst())
            reqString = "8x " + bytes1.stringRepresentation(condensedWith: bytes2, stoppedEarly: stoppedEarly)
        }
        else {
            reqString = "8x " + Array(PTZUnknownRequest(commandBytes: [category, register], arg: nil).bytes.dropFirst()).stringRepresentation
            reqString += stoppedEarly ? "+" : ""
        }

        firstColLength = max(firstColLength, reqString.count)
        reqString = reqString.padding(toLength: firstColLength, withPad: " ", startingAt: 0)
        
        let string = "\(reqString) | \(reqKnown) | \(reply)"
        totalLength = max(totalLength, string.count)
        print(string)
    }
}

private struct FuzzerCategory {
    let category: UInt8
    let registers: Range<UInt8>
    let testArgs: Bool
    let maxArgIfNothingFound: UInt16
    let restore: Bool
    let name: String
    
    init(_ category: UInt8, r: Range<UInt8> = 0..<0x80, args: Bool = false, maxArg: UInt16 = 0x100, restore: Bool = false, _ name: String) {
        self.category = category
        self.registers = r
        self.testArgs = args
        self.maxArgIfNothingFound = maxArg
        self.restore = restore
        self.name = name
        
        if restore && category < 0x40 {
            fatalError("Category \(category) is not restorable !")
        }
    }
}

private struct FuzzerResult {
    let reply: PTZReply
    let bytes: Bytes
    let firstArg: UInt16
    var lastArg: UInt16
    var argRange: UInt16 {
        return lastArg - firstArg
    }
    var stoppedEarly: Bool = false

    var validityLevel: Int /* 0 is worst validity */ {
        // those shouldn't happen, but just in case...
        if (reply is PTZReplyAck)       { return 1 }
        if (reply is PTZReplyReset)     { return 0 }
        if (reply is PTZReplyFail)      { return 0 }
        
        // most common cases
        if (reply is PTZReplyExecuted)  { return 5 }
        if let r = reply as? PTZReplyNotExecuted {
            switch r.error {
            case .modeCondition:    return 4
            case .syntaxError:      return 3
            default:                return 2
            }
        }
        
        // reply is none of the error cases or basic success, it has to be a worded reply (getter reply or unknown)
        return 6
    }
}

