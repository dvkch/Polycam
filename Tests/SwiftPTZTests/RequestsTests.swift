//
//  RequestsTests.swift
//
//
//  Created by syan on 03/07/2024.
//

import Foundation

import XCTest
@testable import SwiftPTZ

final class RequestsTests: XCTestCase {
    lazy var camera: Camera = {
        let serial = try! Serial(tag: "PTZ", name: .firstAvailable!)
        serial.logLevel = .warning

        let camera = Camera(serial: serial)
        camera.logLevel = .info
        
        return camera
    }()
    
    func testPositionRequests() {
        var triplets = [(PTZPositionPan, PTZPositionTilt, PTZPositionZoom)]()
        /*for pan in stride(from: PTZPositionPan.minValue, to: PTZPositionPan.maxValue, by: 10_000) {
            triplets.append((.init(rawValue: pan), .init(rawValue: 0), .init(rawValue: 0)))
        }
        for tilt in stride(from: PTZPositionTilt.minValue, to: PTZPositionTilt.maxValue, by: 10_000) {
            triplets.append((.init(rawValue: 0), .init(rawValue: tilt), .init(rawValue: 0)))
        }*/
        for zoom in stride(from: PTZPositionZoom.minValue, to: PTZPositionZoom.maxValue, by: 1000) {
            triplets.append((.init(rawValue: 0), .init(rawValue: 0), .init(rawValue: zoom)))
        }

        for triplet in triplets {
            let replySet = camera.sendRequest(PTZRequestSetPosition(pan: triplet.0, tilt: triplet.1, zoom: triplet.2))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            Thread.sleep(forTimeInterval: 0.5)
            
            let replyGet = camera.sendRequest(PTZRequestGetPosition())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyPosition)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).pan.rawValue, triplet.0.rawValue, accuracy: 5)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).tilt.rawValue, triplet.1.rawValue, accuracy: 5)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).zoom.rawValue, triplet.2.rawValue, accuracy: 5)
        }
    }
    
    func testBrighntessRequests() {
        for brightness in stride(from: PTZBrightness.minValue, to: PTZBrightness.maxValue, by: 1) {
            let replySet = camera.sendRequest(PTZRequestSetBrightness(brightness: .init(rawValue: brightness)))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetBrightness())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyBrightness)
            XCTAssertEqual((replyGet[1] as! PTZReplyBrightness).brightness.rawValue, brightness)
        }
    }
}
