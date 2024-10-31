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
    case timeout
    case fail
    case reset
    case notExecuted(error: PTZReply.CommandError)
    case missingReply
    case wrongReply(PTZReply)
}

class Camera: Loggable {
    
    // MARK: Init
    init(serial: Serial.Name, logLevel: LogLevel, powerOffAfterUse: Bool) throws(CameraError) {
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
}

// MARK: Base level communication
extension Camera {
    private func communicate(_ request: PTZRequest) -> Bytes {
        // Prevent multiple requests to be run concurrently
        requestLock.lock()
        defer { requestLock.unlock() }
        
        // Send bytes
        log(.info, request.description)
        log(.debug, "> \(request.bytes.hexString)")
        serial.sendBytes(request.bytes)
        
        // Read bytes, up until we have received complete messages or timeout
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
        log(.debug, "< \(bytes.hexString)")

        return bytes
    }

    enum RetryConditions {
        case untilAck
        case onError(PTZReply.CommandError)
        case rescueModeCondition(maxTries: Int)
    }

    @discardableResult
    func send(_ request: PTZRequest, retries: [RetryConditions] = []) -> PTZReply {
        var bytes: Bytes
        
        while true {
            // Serial communication
            bytes = communicate(request)
            
            // Parse reply
            let replies = PTZMessage.replies(from: bytes)
            log(.info, replies.map(\.description).joined(separator: ", "))
            
            // Handle retries
            var shouldRetry: Bool = false
            for retry in retries {
                switch retry {
                case .untilAck:
                    if !replies.contains(where: { if case .ack = $0 { true } else { false } }) {
                        Thread.sleep(forTimeInterval: 0.2)
                        shouldRetry = true
                    }
                    
                case .onError(let error):
                    if replies.contains(where: { $0 == .notExecuted(error: error) }) {
                        Thread.sleep(forTimeInterval: 0.2)
                        shouldRetry = true
                    }

                case .rescueModeCondition(let max):
                    if replies.contains(where: { $0 == .notExecuted(error: .modeCondition) }) && request.modeConditionRescueRequests.isNotEmpty {
                        for rescue in request.modeConditionRescueRequests {
                            _ = self.send(rescue, retries: max > 0 ? [.rescueModeCondition(maxTries: max - 1)] : [])
                        }
                        shouldRetry = true
                    }
                }
            }
            
            if !shouldRetry {
                break
            }
        }

        let replies = PTZMessage.replies(from: bytes)

        // Wait a bit if needed
        if request.waitingTimeIfExecuted > 0 && replies.contains(where: { if case .executed = $0 { true } else { false } }) {
            Thread.sleep(forTimeInterval: request.waitingTimeIfExecuted)
        }

        return replies.element(at: 1) ?? .timeout
    }
}

// MARK: High level communication
extension Camera {
    func run(_ request: PTZActionRequest, rescueModeCondition: Bool = false) throws(CameraError) {
        let reply = send(request, retries: rescueModeCondition ? [.rescueModeCondition(maxTries: 3)] : [])
        switch reply {
        case .ack:                  return
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             return
        case .notExecuted(let e):   throw .notExecuted(error: e)
        case .specific:             return
        case .unknown:              return
        }
    }
    
    func get<T: PTZSpecificReply>(_ request: any PTZGetRequest<T>, rescueModeCondition: Bool = false) throws(CameraError) -> T {
        let reply = send(request, retries: rescueModeCondition ? [.rescueModeCondition(maxTries: 3)] : [])
        switch reply {
        case .ack:                  throw .missingReply
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             throw .missingReply
        case .notExecuted(let e):   throw .notExecuted(error: e)
        case .specific(_, let r):   return r as! T
        case .unknown:              throw .wrongReply(reply)
        }
    }
}
