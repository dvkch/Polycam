//
//  TestCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct TestCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "test")
    
    func run() throws {
        for pair in data {
            let valuePTZ = pair[0].bytes
            let value232 = pair[1].bytes
            
            var sum: [UInt8] = []
            valuePTZ.forEach { byte in
                sum.append(0xFF - byte / 2)
            }
            print("---------------------")
            print("PTZ:", valuePTZ.stringRepresentation)
            print("232:", value232.stringRepresentation)
            print("Sum:", sum.stringRepresentation)
        }
        print("-----------")
        print((0xFF - 0x8D / 2).stringRepresentation)
    }

    var data = [
        ["8D 41 51 20 00 00 00 00 00 7A 03 00 04 7A", "B9 DF 57 F3 FF FF FF FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 00 48 00 00 7A 03 00 04 7A", "B9 DF 57 BB FF 6F FF FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 01 10 00 00 7A 03 00 04 7A", "B9 DF 57 BB FD BE FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 20 00 02 58 00 00 7A 03 00 04 7A", "B9 DF 57 F3 FB 9E FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 20 00 03 20 00 00 7A 03 00 04 7A", "B9 DF 57 F3 F9 BF FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 04 7A", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 04 30 00 00 7A 03 00 04 7A", "B9 DF 57 BB F7 3E FF FF 0B F2 FF F7 16 00"],
        ["8D 41 51 20 00 05 78 00 00 7A 03 00 04 7A", "B9 DF 57 F3 F5 0F FF FF 0B F2 FF F7 16 00"],
        ["8D 41 51 20 00 06 40 00 00 7A 03 00 04 7A", "B9 DF 57 F3 F3 7F FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 20 00 07 08 00 00 7A 03 00 04 7A", "B9 DF 57 F3 F1 DE FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 07 50 00 00 7A 03 00 04 7A", "B9 DF 57 BB F1 BE FF FF 0B F2 FF F7 16 00"],
        
        ["8D 41 51 04 00 03 68 00 00 00 03 00 04 7A", "B9 DF 57 9F F9 2F FE FF FF F9 FF F7 16 00"],
        ["8D 41 51 04 00 03 68 00 00 32 03 00 04 7A", "B9 DF 57 9F F9 2F FE FF 9B F2 FF F7 16 00"],
        ["8D 41 51 04 00 03 68 00 00 64 03 00 04 7A", "B9 DF 57 9F F9 2F FE FF 37 F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 00 16 03 00 04 7A", "B9 DF 57 BB F9 2F FE FF D3 F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 00 48 03 00 04 7A", "B9 DF 57 BB F9 2F FE FF 6F F9 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 04 7A", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 04 00 03 68 00 01 2C 03 00 04 7A", "B9 DF 57 9F F9 2F FE FD 4E F2 FF F7 16 00"],
        ["8D 41 51 04 00 03 68 00 01 5E 03 00 04 7A", "B9 DF 57 9F F9 2F FE FD 86 F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 01 10 03 00 04 7A", "B9 DF 57 BB F9 2F FE FD BE F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 01 42 03 00 04 7A", "B9 DF 57 BB F9 2F FE FD F6 F9 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 01 74 03 00 04 7A", "B9 DF 57 BB F9 2F FE FD 2E F9 FF F7 16 00"],
        
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 00 3C", "B9 DF 57 BB F9 2F FE FF 0B F2 FF FF 7F 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 01 15", "B9 DF 57 BB F9 2F FE FF 0B F2 FF FD AA 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 02 01 6E", "B9 DF 57 BB F9 2F FE FF 0B F2 FB FA 46 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 02 02 48", "B9 DF 57 BB F9 2F FE FF 0B F2 FB F6 DE 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 02 03 21", "B9 DF 57 BB F9 2F FE FF 0B F2 FB F2 BD 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 04 7A", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F7 16 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 05 53", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F5 59 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 06 2C", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F3 A7 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 00 07 06", "B9 DF 57 BB F9 2F FE FF 0B F2 FF F1 E6 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 02 07 5F", "B9 DF 57 BB F9 2F FE FF 0B F2 FB E2 82 00"],
        ["8D 41 51 24 00 03 68 00 00 7A 03 02 08 38", "B9 DF 57 BB F9 2F FE FF 0B F2 FB DE 2A 00"]
    ]
    
}
