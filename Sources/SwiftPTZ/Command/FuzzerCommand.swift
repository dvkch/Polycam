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

    mutating func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error

        Thread.sleep(forTimeInterval: 2)
        
        let d = Date()
        try fuzz(camera: camera, initialState: { () throws(CameraError) -> () in
            try camera.sendRequest(PTZRequestSetDevMode(enabled: .on))
            try camera.sendRequest(PTZRequestSetPosition(pan: .mid, tilt: .mid, zoom: .min))
            try camera.sendRequest(PTZRequestSetAutoFocus(enabled: .off))
        })
        speak("Done")

        printCategoryName("Stats")
        print("Duration:", Int(Date().timeIntervalSince(d)), "seconds")
        print("First column width:", firstColLength, "chars")
    }
    
    private mutating func fuzz(camera: Camera, initialState: () throws(CameraError) -> ()) throws(CameraError) {
        let forbiddenCommands: [(Bytes, String)] = [
            ([0x41, 0x00], "Standby mode"), // Standby mode: affects the next commands
            ([0x41, 0x10], "Mire mode"),    // Mire mode: affects the next commands
            ([0x41, 0x13], "Video output"), // Video output: slow to restore itself
            ([0x41, 0x21], "LED mode"),     // LED mode: sometimes the reply isn't properly parsable
            ([0x41, 0x70], "Unknown"),      // Unknown: weird things happen there (missing ACKs, etc)...
            ([0x45, 0x14], "DrunkTest"),    // DrunkTest: runs for 2min and keeps the camera unusable while it does
            ([0x45, 0x32], "Reset"),        // Reset: takes a while to recover
        ]
        
        // here are the possible commands to be found. commands starting by 0x usually are getters, commands starting by 4x are their corresponding setters
        let categories: [FuzzerCategory] = [
            .init(0x01, "Getters"),
            .init(0x02, "Getters"),
            .init(0x03, "Getters"),
            // .init(0x04, "Unknown"),                              // - not executed: syntax error
            // .init(0x05, "Unknown"),                              // - not executed: command not defined
            .init(0x06, "Hello"),
            // .init(0x07, "Unknown"),                              // - not executed: syntax error
            // .init(0x08, "Unknown"),                              // - not executed: syntax error
            // .init(0x09, "Unknown"),                              // - not executed: syntax error
            // .init(0x0A, "Unknown"),                              // - not executed: syntax error
            // .init(0x0B, "Unknown"),                              // - not executed: syntax error
            // .init(0x0C, "Unknown"),                              // - not executed: syntax error
            // .init(0x0D, "Unknown"),                              // - not executed: syntax error
            // .init(0x0E, "Unknown"),                              // - not executed: syntax error
            // .init(0x0F, "Unknown"),                              // - not executed: syntax error

            .init(0x41, args: true, restore: true, "Setters"),
            .init(0x42, args: true, restore: true, "Setters"),
            .init(0x43, args: true, restore: true, "Setters"),
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
                if let forbidden = forbiddenCommands.first(where: { $0.0 == [category.category, register] }) {
                    printSkipped(cat: category.category, reg: register, description: forbidden.1)
                    continue
                }
                
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
                do {
                    let req = PTZUnknownRequest(commandBytes: [category.category, register], arg: nil)
                    let (replyBytes, reply) = try camera.sendRequest2(req)
                    printResult(.init(category: category.category, register: register, reply: reply, replyBytes: replyBytes, sentArg: false, firstArg: 0, lastArg: 0))
                }
                catch {}
                
                // try the given range of arguments, group the results by type of reply to reduce the amount of information printed
                guard category.testArgs else { continue }
                var replies: [FuzzerResult] = []
                for arg: UInt16 in 0..<0x4000 {
                    if category.category == 0x43 || category.category == 0x45 {
                        // moving pan, tilt, zoom and focus sometimes replies with Mode condition error when going too
                        // fast, let's make this section a wee bit slower to prevent those intermittent errors
                        usleep(10_000)
                    }

                    let req = PTZUnknownRequest(commandBytes: [category.category, register], arg: arg)
                    let (replyBytes, reply) = try camera.sendRequest2(req)
                    if (reply as? PTZReplyNotExecuted)?.error == .commandNotDefined { break }

                    // this command has a new kind of reply, let's create a new group
                    if replyBytes != replies.last?.replyBytes {
                        replies.append(.init(category: category.category, register: register, reply: reply, replyBytes: replyBytes, sentArg: true, firstArg: arg, lastArg: arg))
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
                        if replies.count > 1, replies.last!.argSpan > 0x20 {
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
                    printResult(reply)
                }
            }
        }
    }
    
    mutating func printCategoryName(_ name: String) {
        print("")
        print("")
        print(name)
        print(String(repeating: "-", count: name.count))
    }
    
    private func printSkipped(cat: UInt8, reg: UInt8, description: String) {
        let requestName = ("8x " + [cat, reg].stringRepresentation).padding(toLength: firstColLength, withPad: " ", startingAt: 0)
        print("\(requestName) | X | Skipped: \(description)")
    }

    private mutating func printResult(_ result: FuzzerResult) {
        guard result.shouldBeIncludedInOutput else { return }

        var outputDetails = result.outputDetails
        firstColLength = max(firstColLength, outputDetails.requestName.count)
        outputDetails.requestName = outputDetails.requestName.padding(toLength: firstColLength, withPad: " ", startingAt: 0)

        print("\(outputDetails.requestName) | \(outputDetails.reqKnown ? "X" : " ") | \(outputDetails.replyName)")
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
    let category: UInt8
    let register: UInt8
    let reply: PTZReply
    let replyBytes: Bytes
    let sentArg: Bool
    let firstArg: UInt16
    var lastArg: UInt16
    var argSpan: UInt16 {
        return lastArg - firstArg
    }
    var argRange: ClosedRange<UInt16>? {
        return sentArg ? firstArg...lastArg : nil
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

extension FuzzerResult {
    var shouldBeIncludedInOutput: Bool {
        guard !(reply is PTZReplyFail) else { return false }
        guard (reply as? PTZReplyNotExecuted)?.error != .commandNotDefined else { return false }
        guard argRange?.isEmpty != true else { return false }
        return true
    }
    
    var outputDetails: (requestName: String, replyName: String, reqKnown: Bool) {
        var requestName: String
        var replyName: String
        var isRequestKnown = (!(reply is PTZReplyUnknown) && !(reply is PTZReplyNotExecuted))
        
        // Pretty printing of the request string, could be "8x 06 77" as well as "8x 43 00 (00 -> 02 00+)"
        if let argRange {
            let bytes1 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: argRange.first!).bytes.dropFirst())
            let bytes2 = Array(PTZUnknownRequest(commandBytes: [category, register], arg: argRange.last!).bytes.dropFirst())
            requestName = "8x " + bytes1.stringRepresentation(condensedWith: bytes2, stoppedEarly: stoppedEarly)
        }
        else {
            requestName = "8x " + Array(PTZUnknownRequest(commandBytes: [category, register], arg: nil).bytes.dropFirst()).stringRepresentation
            requestName += stoppedEarly ? "+" : ""
        }
        
        // Setters only reply using "Executed". Since the message format is symetrical (meaning the reply from a getter uses the exact same bytes as the corresponding
        // setter request for the same value), we can try to add more information to our output
        replyName = reply.description
        if (reply is PTZReplyExecuted || reply is PTZReplyNotExecuted) {
            if let equivalentRequest = PTZMessage.replies(from: PTZUnknownRequest(commandBytes: [category, register], arg: argRange?.first).bytes).first, !(equivalentRequest is PTZReplyUnknown) {
                isRequestKnown = true
                replyName += ": \(equivalentRequest)"
            }
            else if category == 0x45, let direction = PTZDirection(rawValue: register) {
                isRequestKnown = true
                replyName += ": Move \(direction)"
            }
            else if category == 0x45, register == 0x17 {
                isRequestKnown = true
                replyName += ": \(PTZRequestStartManualWhiteBalanceCalibration())"
            }
            else if category == 0x45, register == 0x32 {
                isRequestKnown = true
                replyName += ": \(PTZRequestReset(reset: .sensorAndMotors))"
            }
            else {
                isRequestKnown = false
            }
        }
        
        return (requestName, replyName, isRequestKnown)
    }
}

