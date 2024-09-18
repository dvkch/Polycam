//
//  Camera.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation

enum CameraError: Error {
    case unknown
    case missingAck
    case replyTimeout
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
    func get<T: PTZReply>(_ request: any PTZGetRequest<T>) throws -> T {
        let reply: (any PTZReply) = try sendRequest(request)
        return reply as! T
    }
    
    @discardableResult
    func sendRequest(_ request: PTZRequest) throws -> any PTZReply {
        return (try sendRequest2(request)).1
    }

    func sendRequest2(_ request: PTZRequest) throws -> (Bytes, any PTZReply){
        let (bytes, replies) = sendRequest(request, timeout: 1, repeatUntilAck: false, errorToRetry: nil)
        guard replies.count == 2, replies[0] is PTZReplyAck else {
            log(.fatal, "Unexpected camera reply for \(request): \(replies) (expected ACK, then a reply)")
            throw CameraError.missingAck
        }
        return (bytes, replies[1])
    }

    subscript<T: PTZValue>(_ state: any PTZState<T>) -> T? {
        get {
            let (bytes, _) = sendRequest(state.getRequest(), timeout: 1, repeatUntilAck: false, errorToRetry: nil)
            return state.parseResponse(bytes)
        }
        set {
            try! sendRequest(state.setRequest(value: newValue ?? T.default))
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
            PTZRequestSetInvertedMode(enabled: .off),
            PTZRequestSetAutoFocus(enabled: .on),
            PTZRequestSetBrightness(brightness: .default),
            PTZRequestSetSaturation(saturation: .default),
            PTZRequestSetMireMode(enabled: .off),
            PTZRequestSetWhiteBalance(mode: .default),
            PTZRequestSetGainMode(gain: .default),
            PTZRequestSetRedGain(gain: .default),
            PTZRequestSetBlueGain(gain: .default),
            PTZRequestSetBacklightCompensation(enabled: .off)
        ]

        log(.info, "Starting boot sequence...")
        for request in sequence {
            sendRequest(request, timeout: 1, repeatUntilAck: !(request is PTZRequestSetStandbyMode), errorToRetry: .modeCondition)
        }
        log(.info, "Finished boot sequence")
    }
    
    func powerOff() {
        #warning("set off back")
        _ = try? sendRequest2(PTZRequestSetLedMode(color: .off, mode: .off))
        _ = try? sendRequest2(PTZRequestSetStandbyMode(mode: .on)) // TODO: maybe it disconnects the port ?
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
        var receivedMessageInLastLoop = false

        while Date().timeIntervalSince(startDate) < timeout {
            let newBytes = serial.readAllBytes()
            receivedMessageInLastLoop = !newBytes.isEmpty
            bytes.append(contentsOf: newBytes)
            
            if !bytes.isEmpty, !receivedMessageInLastLoop, PTZMessage.messages(from: bytes).allSatisfy(\.isValidLength) {
                break
            }

            // we used to use 20_000us here, allowing us to receive all the message in 2-3 loops, but resulting in ~75ms delay
            // to get a simple response. by switching to a shorter sleep time we usually get the reply in 15 loops, but in 15ms
            usleep(1000)
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
