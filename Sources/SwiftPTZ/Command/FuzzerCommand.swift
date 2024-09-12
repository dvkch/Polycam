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

    func run(camera: Camera) throws {
        camera.logLevel = .error
        try camera.sendRequest(PTZRequestSetAutoFocus(enabled: false))
        Thread.sleep(forTimeInterval: 2)
        
        for category: UInt8 in [0x01, 0x02, 0x03, 0x06, 0x44, 0x45] {
            for register: UInt8 in 0x00...0x7F {
                var possibleArgs: [Int?] = [nil]
                if category == 0x45 {
                    possibleArgs += Array(0..<255)
                }
                
                for arg in possibleArgs {
                    let request = PTZUnknownRequest(commandBytes: [category, register], arg: arg)
                    let reply = try camera.sendRequest(request)
                    if reply is PTZReplyFail || (reply as? PTZReplyNotExecuted)?.error == .commandNotDefined { continue }
                    
                    print(request.bytes.stringRepresentation.padding(toLength: 4 * 3, withPad: " ", startingAt: 0), "|", reply.description)
                    //testCommands.append(.init(command: (register, subreg), kind: .custom([nil, 0x00, 0x01]), originalValue: <#T##Int?#>))
                }
            }
        }
        
        speak("Done")
    }
}
