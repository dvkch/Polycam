//
//  ReadCommandTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
@testable import ptz

final class ReadCommandTests: XCTestCase {
    func testReadAll() {
        do {
            let all = try ptzReadParsed(ReadAll.self, ["all"])
            XCTAssert(all.device.hasPrefix("/dev/"))
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testDistinctOutputs() throws {
        let parsed = try ptzReadParsed(ReadBrightness.self, ["brightness"])

        let expectedStdOut =
        """
        {
          "brightness" : {
            "name" : "\(parsed.brightness.name)",
            "value" : \(parsed.brightness.value)
          },
          "device" : "\(parsed.device)"
        }
        """

        let expectedStdErr =
        """
        Serial RS423: Opening port...
        Serial RS423: > opened!
        Serial RS423: > started reading bytes
        Device: Power
        Device: ACK, Power(on)
        Device: Brightness
        Device: ACK, Brightness(\(parsed.brightness.name))
        Serial RS423: Closed port
        """

        let (stdOut, stdErr) = try ptz(["read", "brightness", "--log=info"])
        XCTAssertEqual(stdOut, expectedStdOut)
        XCTAssertEqual(stdErr, expectedStdErr)
    }
}
