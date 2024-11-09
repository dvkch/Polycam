//
//  WriteCommandTests.swift
//  PTZ
//
//  Created by syan on 09/11/2024.
//

import XCTest
@testable import ptz

final class WriteCommandTests: XCTestCase {
    func testBoot() {
        do {
            let output = try ptz(["write", "boot"]).stdOut
            XCTAssertNotNil(try? #/-> boot, (\d)+ms/#.wholeMatch(in: output))
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPause() {
        do {
            let output = try ptz(["write", "pause=1.3"]).stdOut
            XCTAssertNotNil(try? #/-> pause=1\.3, 130\dms/#.wholeMatch(in: output))
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testWriteDiscreetValue() {
        do {
            let values: [(givenValue: Int, setValue: String, readValueInt: Int, readValueString: String)] = [
                ( 0, "off",    0, "off"),
                (60, "60min", 60, "60min"),
                (72, "60min", 60, "60min"),
                (78, "90min", 90, "90min")
            ]
            
            let regex = #/-> SleepTimeout\((?<setValue>.*)\), (?<duration>\d)+ms/#
            for value in values {
                let output = try ptz(["write", "sleepTimeout=\(value.givenValue)"])
                guard let match = (try? regex.wholeMatch(in: output.stdOut))?.output else {
                    XCTFail("Unexpected output:\n\(output)")
                    continue
                }
                
                XCTAssertEqual(String(match.setValue), value.setValue)
                XCTAssertEqual(output.stdErr, "")

                let readValue = try ptzReadParsed(ReadSleepTimeout.self, ["sleepTimeout"])
                XCTAssertEqual(readValue.sleepTimeout.value, value.readValueInt)
                XCTAssertEqual(readValue.sleepTimeout.name,  value.readValueString)
            }
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnknownState() {
        do {
            let expectedErr =
            """
            Error: The value 'bunny=10' is invalid for '<operations>': Unknown operation
            Help:  <operations>  Operations (boot, pause=secs, or any state(variant)=value)
            Usage: ptz write [--device <device>] [--log <log>] [--continue <continue>] [<operations> ...]
              See 'ptz write --help' for more information.
            """
            
            let output = try ptz(["write", "bunny=10"])
            XCTAssertEqual(output.stdOut, "")
            XCTAssertEqual(output.stdErr, expectedErr)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnknownVariant() {
        do {
            let expectedErr =
            """
            Error: The value 'clock(t3)=0' is invalid for '<operations>': Invalid parameters for state "clock"
            Help:  <operations>  Operations (boot, pause=secs, or any state(variant)=value)
            Usage: ptz write [--device <device>] [--log <log>] [--continue <continue>] [<operations> ...]
              See 'ptz write --help' for more information.
            """

            let output = try ptz(["write", "clock(t3)=0"])
            XCTAssertEqual(output.stdOut, "")
            XCTAssertEqual(output.stdErr, expectedErr)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnknownValue() {
        do {
            let expectedErr =
            """
            Error: The value 'clock(t1)=-1' is invalid for '<operations>': Invalid parameters for state "clock"
            Help:  <operations>  Operations (boot, pause=secs, or any state(variant)=value)
            Usage: ptz write [--device <device>] [--log <log>] [--continue <continue>] [<operations> ...]
              See 'ptz write --help' for more information.
            """

            let output = try ptz(["write", "clock(t1)=-1"])
            XCTAssertEqual(output.stdOut, "")
            XCTAssertEqual(output.stdErr, expectedErr)
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
}
