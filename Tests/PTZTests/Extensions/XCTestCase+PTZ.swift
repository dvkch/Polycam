//
//  XCTestCase+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest

/// https://github.com/swiftlang/swift-package-manager/blob/main/Fixtures/Miscellaneous/TestableExe/Tests/TestableExeTests/TestableExeTests.swift
extension XCTestCase {
    func ptz(_ args: [String]) throws -> (stdOut: String, stdErr: String) {
        let pipeOut = Pipe()
        let pipeErr = Pipe()
        
        let process = Process()
        process.executableURL = URL.productsDirectory.appendingPathComponent("ptz")
        process.arguments = args
        process.standardOutput = pipeOut
        process.standardError = pipeErr
        try process.run()
        process.waitUntilExit()

        let stdOutData = pipeOut.fileHandleForReading.readDataToEndOfFile()
        let stdErrData = pipeErr.fileHandleForReading.readDataToEndOfFile()

        let stdOut = String(data: stdOutData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        let stdErr = String(data: stdErrData, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)

        return (stdOut, stdErr)
    }
    
    func ptzReadParsed<T: Decodable>(_ type: T.Type, _ args: [String]) throws -> T {
        let jsonDecoder = JSONDecoder()
        let stdOutAll = (try ptz(["read"] + args)).stdOut
        let stdOutAllData = Data(stdOutAll.utf8)
        return try jsonDecoder.decode(type, from: stdOutAllData)
    }
}
