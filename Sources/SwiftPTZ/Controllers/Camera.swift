//
//  Camera.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation

class Camera: Loggable {
    
    // MARK: Init
    init(serial: Serial, logLevel: LogLevel, powerOffAfterUse: Bool) {
        self.logLevel = logLevel
        self.serial = serial
        self.powerOffAfterUse = powerOffAfterUse
        self.powerOn()
    }
    
    deinit {
        if powerOffAfterUse {
            powerOff()
        }
        serial.stop()
    }
    
    // MARK: Properties
    private let serial: Serial
    private let powerOffAfterUse: Bool
    let logLevel: LogLevel
    let logTag: String = "Camera"

    // MARK: Public actions
    @discardableResult
    func sendRequest(_ request: PTZRequest) -> [any PTZReply] {
        sendRequest(request, timeout: 1, repeatUntilAck: false)
    }

    func powerOn() {
        sendRequest(PTZRequestSetStandbyMode(mode: .off), timeout: 0.1, repeatUntilAck: false)
        sendRequest(PTZRequestSetPosition(pan: .default, tilt: .default, zoom: .default), timeout: 1, repeatUntilAck: true)
    }
    
    func powerOff() {
        sendRequest(PTZRequestSetStandbyMode(mode: .on))
    }

    // MARK: Actions

    @discardableResult
    private func sendRequest(_ request: PTZRequest, timeout: TimeInterval, repeatUntilAck: Bool) -> [any PTZReply] {
        log(.info, request.description)
        log(.debug, "> \(request.bytes.stringRepresentation)")
        serial.sendBytes(request.bytes)
        
        let startDate = Date()
        var bytes = Bytes()
        var justReceivedBytes = false

        while Date().timeIntervalSince(startDate) < timeout && (bytes.isEmpty || justReceivedBytes) {
            let newBytes = serial.readAllBytes()
            bytes.append(contentsOf: newBytes)
            if newBytes.count > 0 {
                justReceivedBytes = true
            }
            else {
                justReceivedBytes = false
            }
            usleep(20_000)
        }

        log(.debug, "< \(bytes.stringRepresentation)")

        let replies = PTZMessage.replies(from: bytes)
        log(.info, replies.map(\.description).joined(separator: ", "))
        
        if repeatUntilAck && !replies.contains(where: { $0 is PTZReplyAck }) {
            Thread.sleep(forTimeInterval: 1)
            return sendRequest(request, timeout: timeout, repeatUntilAck: repeatUntilAck)
        }
        
        if request.waitingTimeIfExecuted > 0 && replies.contains(where: { $0 is PTZReplyExecuted }) {
            Thread.sleep(forTimeInterval: request.waitingTimeIfExecuted)
        }

        return replies
    }
}
