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
    
    @Option(name: .customLong("complete"), help: "Makes sure all possible requests are evaluated, can be very slow")
    var complete: Bool = false
    
    mutating func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error

        Thread.sleep(forTimeInterval: 2)
        
        let d = Date()
        let count = try fuzz(camera: camera, initialState: { () throws(CameraError) -> () in
            try camera.sendRequest(PTZRequestSetDevMode(enabled: .on))
            try camera.sendRequest(PTZRequestSetPosition(pan: .mid, tilt: .mid, zoom: .min))
            try camera.sendRequest(PTZRequestSetAutoFocus(enabled: .off))
        })
        speak("Done")

        let stats = [
            ["Duration", String(Int(Date().timeIntervalSince(d)))],
            ["Requests sent", String(count)]
        ]
        Printer.printHeader("Stats")
        Printer.printTable(stats, headers: ["Name", "Value"], closeLastColumn: true)
    }
    
    private var categories: [FuzzerCategory] {
        // here are the possible commands to be found. commands starting by 0x usually are getters, commands starting by 4x are their corresponding setters
        var categories: [FuzzerCategory] = [
            .init(0x01, "Getters"),
            .init(0x02, "Getters"),
            .init(0x03, "Getters"),
            .init(0x04, "Unknown"), // - not executed: syntax error
            .init(0x05, "Unknown"), // - not executed: command not defined
            .init(0x06, "Hello"),
            .init(0x07, "Unknown"), // - not executed: syntax error
            .init(0x08, "Unknown"), // - not executed: syntax error
            .init(0x09, "Unknown"), // - not executed: syntax error
            .init(0x0A, "Unknown"), // - not executed: syntax error
            .init(0x0B, "Unknown"), // - not executed: syntax error
            .init(0x0C, "Unknown"), // - not executed: syntax error
            .init(0x0D, "Unknown"), // - not executed: syntax error
            .init(0x0E, "Unknown"), // - not executed: syntax error
            .init(0x0F, "Unknown"), // - not executed: syntax error
            
            .init(0x41, args: true, restore: true, "Setters"),
            .init(0x42, args: true, restore: true, "Setters"),
            .init(0x43, args: true, restore: true, "Setters"),
            .init(0x44, args: true, "Unknown"), // - not executed: syntax error
            .init(0x45, args: true, "Actions"),
            .init(0x46, args: true, "Unknown"), // - not executed: command not defined
            .init(0x47, args: true, "Unknown"), // - not executed: syntax error
            .init(0x48, args: true, "Unknown"), // - not executed: syntax error
            .init(0x49, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4A, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4B, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4C, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4D, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4E, args: true, "Unknown"), // - not executed: syntax error
            .init(0x4F, args: true, "Unknown"), // - not executed: syntax error
        ]
        
        if !complete {
            let requiredCategories: [UInt8] = [0x01, 0x02, 0x03, 0x06, 0x41, 0x42, 0x43, 0x45]
            categories.removeAll(where: { !requiredCategories.contains($0.category) })
        }
        
        return categories
    }
    
    private mutating func fuzz(camera: Camera, initialState: () throws(CameraError) -> ()) throws(CameraError) -> Int {
        let forbiddenCommands: [(Bytes, String)] = [
            ([0x41, 0x00], "Power mode"),   // Affects the next commands
            ([0x41, 0x10], "Mire mode"),    // Affects the next commands
            ([0x41, 0x13], "Video output"), // Slow to restore itself
            ([0x41, 0x21], "LED mode"),     // Sometimes the reply isn't properly parsable
            ([0x41, 0x70], "Unknown"),      // Weird things happen there (missing ACKs, etc)...
            ([0x43, 0x02], "Zoom"),         // Slow to fuzz
            ([0x43, 0x04], "Pan"),          // Slow to fuzz
            ([0x45, 0x14], "DrunkTest"),    // Runs for 2min and keeps the camera unusable while it does
            ([0x45, 0x32], "Reset"),        // Rakes a while to recover
        ]
        
        var requestsSent: Int = 0
        for category in categories {
            guard !category.registers.isEmpty else { continue }

            var resultTable = [[String]]()
            try initialState()

            for register in category.registers {
                if let forbidden = forbiddenCommands.first(where: { $0.0 == [category.category, register] }) {
                    resultTable.append([
                        ("8x " + [category.category, register].hexString),
                        "  √",
                        "Skipped: \(forbidden.1)"
                    ])
                    continue
                }
                
                // before playing with some setters, let's make sure we can reset them afterwards
                var restoreBlock: () -> () = {}
                if category.restore {
                    requestsSent += 1
                    let (replyBytes, _) = try camera.sendRequest2(PTZUnknownRequest(commandBytes: [category.category - 0x40, register], arg: nil))
                    let restoreBytes = Array(replyBytes.dropFirst(2))
                    if restoreBytes.count > 2, restoreBytes[0] == category.category, restoreBytes[1] == register {
                        restoreBlock = { _ = try? camera.sendRequest(PTZUnknownRequest(commandBytes: restoreBytes, arg: nil)) }
                    }
                }
                defer { restoreBlock() }
                
                // run the command without any argument first
                do {
                    requestsSent += 1
                    let req = PTZUnknownRequest(commandBytes: [category.category, register], arg: nil)
                    let (replyBytes, reply) = try camera.sendRequest2(req)
                    
                    let result = FuzzerResult(category: category.category, register: register, reply: reply, replyBytes: replyBytes, sentArg: false, firstArg: 0, lastArg: 0)
                    if result.shouldBeIncludedInOutput {
                        resultTable.append([
                            result.outputDetails.requestName,
                            result.outputDetails.reqKnown ? "  √" : " ",
                            result.outputDetails.replyName
                        ])
                    }
                }
                catch {}
                
                // try the given range of arguments, group the results by type of reply to reduce the amount of information printed
                guard category.testArgs else { continue }
                var replies: [FuzzerResult] = []
                for arg: UInt16 in 0..<0x4000 {
                    if category.category == 0x43 || category.category == 0x45 {
                        // moving pan, tilt, zoom and focus sometimes replies with Mode condition error when going too
                        // fast, let's make this section a wee bit slower to prevent those intermittent errors
                        usleep(5_000)
                    }

                    requestsSent += 1
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
                    if !complete, with(replies.last!.reply, { $0 is PTZReplyTimeout || $0 is PTZReplyFail || $0 is PTZReplyNotExecuted }) {
                        // not receiving any answer for some time now, let's stop
                        if (replies.last!.reply is PTZReplyTimeout), replies.last!.argSpan > 0x04 {
                            replies[replies.count - 1].stoppedEarly = true
                            break
                        }

                        // if we've already found something else and have gotten this error for a while now: let's stop
                        if replies.count > 1, replies.last!.argSpan > 0x10 {
                            replies[replies.count - 1].stoppedEarly = true
                            break
                        }

                        // if this is the only reply we got and we already searched a while: let's stop
                        if replies.count == 1, arg >= 0x90 {
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
                for reply in replies.filter(\.shouldBeIncludedInOutput) {
                    resultTable.append([
                        reply.outputDetails.requestName,
                        reply.outputDetails.reqKnown ? "  √" : " ",
                        reply.outputDetails.replyName
                    ])
                }
            }

            Printer.printHeader(category.name)
            Printer.printTable(resultTable, headers: ["Request", "Status", "Reply & notes"], closeLastColumn: false)
        }
        
        return requestsSent
    }
}

private struct FuzzerCategory {
    let category: UInt8
    let registers: Range<UInt8>
    let testArgs: Bool
    let restore: Bool
    let name: String
    
    init(_ category: UInt8, r: Range<UInt8> = 0..<0x80, args: Bool = false, restore: Bool = false, _ name: String) {
        self.category = category
        self.registers = r
        self.testArgs = args
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
        if (reply is PTZReplyTimeout)   { return 0 }

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
            requestName = "8x " + bytes1.hexString(condensedWith: bytes2, stoppedEarly: stoppedEarly)
        }
        else {
            requestName = "8x " + Array(PTZUnknownRequest(commandBytes: [category, register], arg: nil).bytes.dropFirst()).hexString
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
            else if category == 0x45, register == 0x13 {
                isRequestKnown = true
                replyName += ": \(PTZRequestStartFocus())"
            }
            else if category == 0x45, register == 0x17 {
                isRequestKnown = true
                replyName += ": \(PTZRequestStartManualWhiteBalanceCalibration())"
            }
            else if category == 0x45, register == 0x32 {
                isRequestKnown = true
                replyName += ": \(PTZRequestReset(reset: .settings))"
            }
            else {
                isRequestKnown = false
            }
        }
        
        return (requestName, replyName, isRequestKnown)
    }
}

