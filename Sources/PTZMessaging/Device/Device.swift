//
//  Device.swift
//  SwiftPTZ
//
//  Created by syan on 05/11/2024.
//

import Foundation
import PTZCommon

open class Device: Loggable {
    
    // MARK: Init
    public init(serial: SerialName, logLevel: LogLevel) throws(DeviceError) {
        self.logLevel = logLevel
        do {
            self.serial = try Serial(device: serial, tag: "RS423", logLevel: logLevel)
        }
        catch {
            throw .serialError(error)
        }
    }

    deinit {
        serial.stop()
    }

    // MARK: Properties
    private let serial: Serial
    private let requestLock: NSLock = .init()
    public var logLevel: LogLevel
    public let logTag: String = "Device"
}

// MARK: Base level communication
extension Device {
    private func communicate(_ request: PTZRequest) -> Bytes {
        // Prevent multiple requests to be run concurrently
        requestLock.lock()
        defer { requestLock.unlock() }
        
        // Send bytes
        log(.info, request.description)
        log(.debug, "> \(request.message.bytes.hexString)")
        serial.sendBytes(request.message.bytes)
        
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
}

// MARK: Interpret replies, allows retries
extension Device {
    public enum RetryConditions {
        case untilAck
        case onError(PTZReply.CommandError)
        case rescueModeCondition(maxTries: Int)
        
        internal static func modeCondition(_ rescue: Bool) -> [RetryConditions] {
            return rescue ? [.rescueModeCondition(maxTries: 3)] : []
        }
    }

    @discardableResult
    public func send(_ request: PTZRequest, retries: [RetryConditions] = []) -> PTZReply {
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
extension Device {
    public func get<T: PTZReadable>(_ state: T.Type, for variant: T.Variant, rescueModeCondition: Bool = false) throws(DeviceError) -> T.Value {
        let reply = send(state.get(for: variant), retries: RetryConditions.modeCondition(rescueModeCondition))
        switch reply {
        case .ack:                  throw .missingReply
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             throw .missingReply
        case .notExecuted(let e):   throw .notExecuted(error: e)
        case .state(_, let s):      return (s as! T).value
        case .unknown:              throw .wrongReply(reply)
        }
    }
    
    public func get<T: PTZReadable>(_ state: T.Type, rescueModeCondition: Bool = false) throws(DeviceError) -> T.Value where T.Variant == PTZNone {
        return try get(state, for: .init(), rescueModeCondition: rescueModeCondition)
    }
    
    public func get<T: PTZReadable>(_ state: T.Type, forCli cliStringVariant: String, rescueModeCondition: Bool = false) throws(DeviceError) -> T.Value? {
        guard let variant = state.Variant.init(from: cliStringVariant) else {
            return nil
        }
        return try get(state, for: variant, rescueModeCondition: false)
    }

    public func set<T: PTZWriteable>(_ state: T, rescueModeCondition: Bool = false) throws(DeviceError) {
        let reply = send(state.set(), retries: RetryConditions.modeCondition(rescueModeCondition))
        switch reply {
        case .ack:                  return
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             return
        case .notExecuted(let e):   throw .notExecuted(error: e)
        case .state:                return
        case .unknown:              return
        }
    }

    public func set<T: PTZReadable & PTZWriteable>(_ state: T, debounce: Bool, rescueModeCondition: Bool = false) throws(DeviceError){
        if debounce, try get(T.self, for: state.variant) == state.value {
            return
        }
        try set(state, rescueModeCondition: rescueModeCondition)
    }
    
    public func get<T: PTZReadableCombo>(_ state: T.Type) throws(DeviceError) -> T.Value {
        var messages = [PTZMessage]()
        for reply in state.get().map({ send($0) }) {
            switch reply {
            case .ack:                  throw .missingReply
            case .reset:                throw .reset
            case .fail:                 throw .fail
            case .timeout:              throw .timeout
            case .executed:             throw .missingReply
            case .notExecuted(let e):   throw .notExecuted(error: e)
            case .state(let b, _):      messages.append(.init(bytes: b))
            case .unknown(let b):       messages.append(.init(bytes: b))
            }
        }
        guard let state = T.init(messages: messages) else { throw .missingReply }
        return state.value
    }
    
    public func set<T: PTZWriteableCombo>(_ state: T) throws(DeviceError) {
        for reply in state.set().map({ send($0) }) {
            switch reply {
            case .ack:                  continue
            case .reset:                throw .reset
            case .fail:                 throw .fail
            case .timeout:              throw .timeout
            case .executed:             continue
            case .notExecuted(let e):   throw .notExecuted(error: e)
            case .state:                continue
            case .unknown:              continue
            }
        }
    }
}
