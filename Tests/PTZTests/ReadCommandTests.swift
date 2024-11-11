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
    
    func testReadHasDistinctOutputs() throws {
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
    
    func testReadMoving() throws {
        let moveOutput = try ptz(["write", "position=0,0,0", "pause=0.5", "movePan(left)=10"])
        XCTAssertTrue(moveOutput.stdOut.contains("-> Position(0, 0, 0)"), "")
        XCTAssertTrue(moveOutput.stdOut.contains("-> pause=0.5"), "")
        XCTAssertTrue(moveOutput.stdOut.contains("-> MovePan(left: 13%)"), "")
        XCTAssertEqual(moveOutput.stdErr, "")

        let afterMoving = try ptzReadParsed(ReadMoving.self, ["moving"])
        XCTAssertTrue(afterMoving.moving.value)

        let stopOutput = try ptz(["write", "movePan(stop)=0"])
        XCTAssertTrue(stopOutput.stdOut.contains("-> MovePan(stop: 0%)"), "")
        XCTAssertEqual(stopOutput.stdErr, "")

        let afterStopping = try ptzReadParsed(ReadMoving.self, ["moving"])
        XCTAssertFalse(afterStopping.moving.value)
    }
}
