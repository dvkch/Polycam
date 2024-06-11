//
//  File.swift
//  
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct SnifferCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "sniff")
    
    @Option(name: .customLong("tx-device"), help: "Device to sniff Tx")
    var txDevice: String = "/dev/cu.usbserial-11110"

    @Option(name: .customLong("rx-device"), help: "Device to sniff Rx")
    var rxDevice: String = "/dev/cu.usbserial-1130"
    
    func run() throws {
        do {
            print("--- Sniffer ---")
            let serialTx = try Serial(tag: "Tx", deviceName: txDevice)
            let serialRx = try Serial(tag: "Rx", deviceName: rxDevice, delay: 0.01)
            
            for command in generateTelnetCommands(wakeSleep: false, move: false, setGetPos: true) {
                Log.w(tag: "----", message: "----------------")
                Log.w(tag: "TELNET", message: command.0)
                if let ptz = command.1 {
                    Log.w(tag: "PTZ ", message: ptz.stringRepresentation)
                }
                runTelnetCommand(command: command.0)
                Thread.sleep(forTimeInterval: command.2)
            }

            serialTx.stop()
            serialRx.stop()
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func generateTelnetCommands(wakeSleep: Bool, move: Bool, setGetPos: Bool) -> [(String, (any PTZRequest)?, TimeInterval)] {
        let wakeTimeout: TimeInterval = 60
        let moveTimeout: TimeInterval = 30
        let shortTimeout: TimeInterval = 1
        var commands = [(String, (any PTZRequest)?, TimeInterval)]()

        if wakeSleep {
            commands.append(("sleep", nil, wakeTimeout))
            commands.append(("wake", nil, wakeTimeout))
            commands.append(("camera near setposition 0 0 0", PTZRequestSetPosition(pan: 0, tilt: 0, zoom: 0), shortTimeout))
            commands.append(("camera near getposition", PTZRequestGetPosition(), shortTimeout))
            commands.append(("sleep", nil, wakeTimeout))
            commands.append(("wake", nil, wakeTimeout))
            commands.append(("camera near setposition 0 0 0", PTZRequestSetPosition(pan: 0, tilt: 0, zoom: 0), shortTimeout))
            commands.append(("camera near getposition", PTZRequestGetPosition(), shortTimeout))
        }
        
        if move {
            let directions: [(String, PTZRequestMove.Direction, PTZRequestStopMove.Direction)] = [
                ("left",    .left,  .horizontal),
                ("right",   .right, .horizontal),
                ("left",    .left,  .horizontal),
                ("right",   .right, .horizontal),
                ("up",      .up,    .vertical),
                ("down",    .down,  .vertical),
                ("up",      .up,    .vertical),
                ("down",    .down,  .vertical),
                ("zoom+",   .zoomIn,  .zoom),
                ("zoom-",   .zoomOut, .zoom),
                ("zoom+",   .zoomIn,  .zoom),
                ("zoom-",   .zoomOut, .zoom),
            ]
            
            for d in directions {
                commands.append(("camera near move \(d.0)", PTZRequestMove(direction: d.1, accelerationPercent: 0), moveTimeout))
                commands.append(("camera near move stop", PTZRequestStopMove(direction: d.2), shortTimeout))
                commands.append(("camera near getposition", PTZRequestGetPosition(), shortTimeout))
            }
        }

        if setGetPos {
            for index in [0, 1, 2] {
                for value in stride(from: -50_000, to: 50_001, by: 10_000) {
                    if index == 0 {
                        commands.append(("camera near setposition \(value) 0 0", PTZRequestSetPosition(pan: .init(value: value), tilt: 0, zoom: 0), shortTimeout))
                    }
                    else if index == 1 {
                        commands.append(("camera near setposition 0 \(value) 0", PTZRequestSetPosition(pan: 0, tilt: .init(value: value), zoom: 0), shortTimeout))
                    }
                    else {
                        commands.append(("camera near setposition 0 0 \(value)", PTZRequestSetPosition(pan: 0, tilt: 0, zoom: .init(value: value)), shortTimeout))
                    }
                    commands.append(("camera near getposition", PTZRequestGetPosition(), shortTimeout))
                }
            }
        }
        return commands
    }

    func runTelnetCommand(command: String) {
        let password = "admin"
        let ip = "192.168.69.133"

        // (brew tap esolitos/ipa && brew install esolitos/ipa/sshpass)
        let bashCommand = "( echo \(password); echo \(command); sleep 1; ) | telnet \(ip) 24 > /dev/null 2>&1 || true"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["bash", "-c", bashCommand]
        try! process.run()
        process.waitUntilExit()
    }
}
