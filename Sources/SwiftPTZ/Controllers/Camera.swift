//
//  Camera.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation
import SwiftSerial

enum CameraError: Error {
    case serialError(PortError)
    case unknown
    case missingAck
    case replyTimeout
    case fail
    case reset
    case notExecuted(error: PTZReplyNotExecuted.PTZCommandError)
}

class Camera: Loggable {
    
    // MARK: Init
    init(serial: SerialName, logLevel: LogLevel, powerOffAfterUse: Bool) throws(CameraError) {
        self.logLevel = logLevel
        do {
            self.serial = try Serial(device: serial, tag: "RS423", logLevel: logLevel)
        }
        catch {
            throw .serialError(error)
        }
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
    private let requestLock: NSLock = .init()
    var logLevel: LogLevel
    let logTag: String = "Camera"

    // MARK: Public actions
    func get<T: PTZReply>(_ request: any PTZGetRequest<T>) throws(CameraError) -> T {
        let reply: (any PTZReply) = try sendRequest(request)
        return reply as! T
    }
    
    @discardableResult
    func sendRequest(_ request: PTZRequest, expectValidResponse: Bool = false) throws(CameraError) -> any PTZReply {
        let response = (try sendRequest2(request)).1
        if expectValidResponse {
            if response is PTZReplyReset {
                throw .reset
            }
            if response is PTZReplyFail {
                throw .fail
            }
            if let r = response as? PTZReplyNotExecuted {
                throw .notExecuted(error: r.error)
            }
        }
        return response
    }

    func sendRequest2(_ request: PTZRequest) throws(CameraError) -> (Bytes, any PTZReply) {
        let (bytes, replies) = sendRequest(request, repeatUntilAck: false, errorToRetry: nil)
        guard replies.first is PTZReplyAck else {
            log(.fatal, "Unexpected camera reply for \(request), expected ACK then a reply, got: \(replies)")
            throw CameraError.missingAck
        }
        return (bytes, replies.last ?? PTZReplyFail())
    }

    subscript<T: PTZValue>(_ state: any PTZState<T>) -> T? {
        get {
            let (bytes, _) = sendRequest(state.getRequest(), repeatUntilAck: false, errorToRetry: nil)
            return state.parseResponse(bytes)
        }
        set {
            try! sendRequest(state.setRequest(value: newValue ?? T.default))
        }
    }

    func powerOn() {
        let sequence: [any PTZRequest] = [
            PTZRequestSetStandbyMode(mode: .unknown1), // off ?
            PTZRequestHelloMPTZ11(),
            PTZRequestSetDevMode(enabled: .on),
            PTZRequestSetMireMode(enabled: .off),
            PTZRequestSetColors(enabled: .on),
            PTZRequestSetLedMode(color: .default, mode: .default),
            PTZRequestSetVideoOutputMode(mode: .default),
            PTZRequestSetShutterSpeed(speed: .default),
            PTZRequestSetVolume(volume: .default),
            // PTZRequestSetPosition(pan: .default, tilt: .default, zoom: .default),
            PTZRequestSetInvertedMode(enabled: .off),
            PTZRequestSetAutoFocus(enabled: .on),
            PTZRequestSetWhiteBalance(mode: .default),
            PTZRequestSetGainMode(gain: .default),
            PTZRequestSetRedGain(gain: .default),
            PTZRequestSetBlueGain(gain: .default),
            PTZRequestSetBrightness(brightness: .default),
            PTZRequestSetSaturation(saturation: .default),
            PTZRequestSetBacklightCompensation(enabled: .off)
        ]

        log(.info, "Starting boot sequence...")
        for request in sequence {
            sendRequest(request, repeatUntilAck: !(request is PTZRequestSetStandbyMode), errorToRetry: .modeCondition)
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
    private func sendRequest(_ request: PTZRequest, repeatUntilAck: Bool, errorToRetry: PTZReplyNotExecuted.PTZCommandError?) -> (Bytes, [any PTZReply]) {
        requestLock.lock()
        defer { requestLock.unlock() }
        
        log(.info, request.description)
        log(.debug, "> \(request.bytes.stringRepresentation)")
        serial.sendBytes(request.bytes)
        
        let startDate = Date()
        var bytes = Bytes()
        var receivedMessageInLastLoop = false

        while Date().timeIntervalSince(startDate) < 0.5 {
            let newBytes = serial.readAllBytes()
            receivedMessageInLastLoop = !newBytes.isEmpty
            bytes.append(contentsOf: newBytes)
            
            if !bytes.isEmpty, !receivedMessageInLastLoop, PTZMessage.receptionComplete(from: bytes) {
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
        
        #warning("support PTZRequest.modeConditionRescueRequest")

        if shouldRetry {
            Thread.sleep(forTimeInterval: 0.2)

            requestLock.unlock()
            let r = sendRequest(request, repeatUntilAck: repeatUntilAck, errorToRetry: errorToRetry)
            requestLock.lock()
            return r
        }
        
        if request.waitingTimeIfExecuted > 0 && replies.contains(where: { $0 is PTZReplyExecuted }) {
            Thread.sleep(forTimeInterval: request.waitingTimeIfExecuted)
        }

        return (bytes, replies)
    }
}
