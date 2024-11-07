//
//  Speak.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation

internal func speak<T: CustomStringConvertible>(_ value: T) {
    speak(value.description)
}

internal func speak(_ string: String) {
    let possibleCommands = ["say", "spd-say", "espeak"]
    guard let command = possibleCommands.lazy.compactMap({ Process.executablePath(for: $0) }).first else {
        print("Couldn't find a preinstalled speak command amongst supported ones (\(possibleCommands.joined(separator: ",")).")
        return
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = [string]
    try? process.run()
}

private extension Process {
    static func executablePath(for name: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [name]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                let outputString = String(data: outputData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
                return outputString
            }
            return nil
        } catch {
            return nil
        }
    }
}
