//
//  Camera.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation

enum CameraError {
    case unknown
    case fail
    case reset
    case notExecuted(error: PTZReplyNotExecuted.PTZCommandError)
}

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
    var logLevel: LogLevel
    let logTag: String = "Camera"

    // MARK: Public actions
    @discardableResult
    func sendRequest(_ request: PTZRequest) -> [any PTZReply] {
        let (_, replies) = sendRequest(request, timeout: 1, repeatUntilAck: false, errorToRetry: nil)
        return replies
    }
    
    subscript<T: PTZValue>(_ state: any PTZState<T>) -> T? {
        get {
            let (bytes, _) = sendRequest(state.getRequest(), timeout: 1, repeatUntilAck: false, errorToRetry: nil)
            return state.parseResponse(bytes)
        }
        set {
            sendRequest(state.setRequest(value: newValue ?? T.default))
        }
    }

    func powerOn() {
        let sequence: [any PTZRequest] = [
            PTZRequestSetStandbyMode(mode: .off),
            PTZRequestHelloMPTZ11(),
            PTZRequestSetLedMode(color: .default, mode: .default),
            PTZRequestSetVideoOutputMode(mode: .default),
            PTZRequestSetShutterSpeed(speed: .default),
            PTZRequestSetVolume(volume: .default),
            PTZRequestSetPosition(pan: .default, tilt: .default, zoom: .default),
            PTZRequestSetInvertedMode(enabled: false),
            PTZRequestSetAutoFocus(enabled: true),
            PTZRequestSetBrightness(brightness: .default),
            PTZRequestSetSaturation(saturation: .default),
            PTZRequestSetMireMode(enabled: false),
            PTZRequestSetWhiteBalance(mode: .default),
            PTZRequestSetGainMode(gain: .default),
            PTZRequestSetRedGain(gain: .default),
            PTZRequestSetBlueGain(gain: .default),
            PTZRequestSetBacklightCompensation(enabled: false)
        ]

        log(.info, "Starting boot sequence...")
        let previousLevel = logLevel
        logLevel = .debug
        for request in sequence {
            sendRequest(request, timeout: 1, repeatUntilAck: !(request is PTZRequestSetStandbyMode), errorToRetry: .modeCondition)
        }
        logLevel = previousLevel
        log(.info, "Finished boot sequence")
    }
    
    func powerOff() {
        #warning("set off back")
        // sendRequest(PTZRequestSetLedMode(mode: .off))
        sendRequest(PTZRequestSetStandbyMode(mode: .on)) // TODO: maybe it disconnects the port ?
        while serial.readAllBytes() != [0x00] {
            Thread.sleep(forTimeInterval: 0.1)
        }

        serial.stop()
    }

    // MARK: Actions
    @discardableResult
    private func sendRequest(_ request: PTZRequest, timeout: TimeInterval, repeatUntilAck: Bool, errorToRetry: PTZReplyNotExecuted.PTZCommandError?) -> (Bytes, [any PTZReply]) {
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

        var shouldRetry = false
        shouldRetry ||= errorToRetry != nil && replies.compactMap({ $0 as? PTZReplyNotExecuted }).first?.error == errorToRetry
        shouldRetry ||= repeatUntilAck && !replies.contains(where: { $0 is PTZReplyAck })

        if shouldRetry {
            Thread.sleep(forTimeInterval: 0.2)
            return sendRequest(request, timeout: timeout, repeatUntilAck: repeatUntilAck, errorToRetry: errorToRetry)
        }
        
        if request.waitingTimeIfExecuted > 0 && replies.contains(where: { $0 is PTZReplyExecuted }) {
            Thread.sleep(forTimeInterval: request.waitingTimeIfExecuted)
        }

        return (bytes, replies)
    }
}
