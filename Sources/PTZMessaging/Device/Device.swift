//
//  Device.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import Foundation

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
        let lockName = serial.rawValue.replacingOccurrences(of: "/", with: "_")
        guard let ipLock = IPLock(path: "/tmp/ptz-serial-\(lockName).lock") else {
            throw .ipLockUnavailable
        }
        self.ipLock = ipLock
    }

    deinit {
        serial.stop()
    }

    // MARK: Properties
    private let serial: Serial
    private let requestLock: NSLock = .init()
    private let ipLock: IPLock
    public var logLevel: LogLevel
    public let logTag: String = "Device"
}

// MARK: Base level communication
extension Device {
    private func communicate(_ request: PTZRequest) -> Bytes {
        requestLock.lock()
        defer { requestLock.unlock() }
        guard ipLock.lock(timeout: 2) else {
            log(.error, "Timed out waiting for exclusive access to the serial port")
            return []
        }
        defer { ipLock.unlock() }

        let maxAttempts = 3
        for attempt in 0..<maxAttempts {
            log(.info, request.description)
            log(.debug, "> \(request.message.bytes.hexString)")
            serial.sendBytes(request.message.bytes)

            let startDate = Date()
            var bytes = Bytes()
            while Date().timeIntervalSince(startDate) < 0.5 {
                let newBytes = serial.readAvailableBytes()
                bytes.append(contentsOf: newBytes)
                if !bytes.isEmpty, newBytes.isEmpty, PTZMessage.receptionComplete(from: bytes) {
                    break
                }
                if newBytes.isEmpty { usleep(1000) }
            }
            log(.debug, "< \(bytes.hexString)")

            if !bytes.isEmpty { return bytes }
            log(.warning, "No reply received, retrying (attempt \(attempt + 1))")
        }
        log(.error, "No reply received after \(maxAttempts) retries, giving up")
        return []
    }
}

// MARK: Interpret replies, allows retries
extension Device {
    public enum RetryConditions {
        case untilAck
        case onError(PTZReply.CommandError)
        case rescueModeCondition(maxTries: Int)
        case untilZeros

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

                case .untilZeros:
                    while serial.readAvailableBytes() != [0x00] {
                        Thread.sleep(forTimeInterval: 0.02)
                    }
                    shouldRetry = false
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
        let request = state.get(for: variant)
        let reply = send(request, retries: RetryConditions.modeCondition(rescueModeCondition))
        switch reply {
        case .ack:                  throw .missingReply
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             throw .missingReply
        case .notExecuted(let e):   throw .notExecuted(error: e, request: request)
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

    public func set<T: PTZWritable>(_ state: T, rescueModeCondition: Bool = false) throws(DeviceError) {
        let request = state.set()
        let reply = send(request, retries: RetryConditions.modeCondition(rescueModeCondition))
        switch reply {
        case .ack:                  return
        case .reset:                throw .reset
        case .fail:                 throw .fail
        case .timeout:              throw .timeout
        case .executed:             return
        case .notExecuted(let e):   throw .notExecuted(error: e, request: request)
        case .state:                return
        case .unknown:              return
        }
    }

    public func set<T: PTZReadable & PTZWritable>(_ state: T, debounce: Bool, rescueModeCondition: Bool = false) throws(DeviceError){
        if debounce, try get(T.self, for: state.variant) == state.value {
            return
        }
        try set(state, rescueModeCondition: rescueModeCondition)
    }

    public func get<T: PTZReadableCombo>(_ state: T.Type) throws(DeviceError) -> T.Value {
        var messages = [PTZMessage]()
        for (request, reply) in state.get().map({ ($0, send($0)) }) {
            switch reply {
            case .ack:                  throw .missingReply
            case .reset:                throw .reset
            case .fail:                 throw .fail
            case .timeout:              throw .timeout
            case .executed:             throw .missingReply
            case .notExecuted(let e):   throw .notExecuted(error: e, request: request)
            case .state(let b, _):      messages.append(.init(bytes: b))
            case .unknown(let b):       messages.append(.init(bytes: b))
            }
        }
        guard let state = T.init(messages: messages) else { throw .missingReply }
        return state.value
    }

    public func set<T: PTZWriteableCombo>(_ state: T) throws(DeviceError) {
        for (request, reply) in state.set().map({ ($0, send($0)) }) {
            switch reply {
            case .ack:                  continue
            case .reset:                throw .reset
            case .fail:                 throw .fail
            case .timeout:              throw .timeout
            case .executed:             continue
            case .notExecuted(let e):   throw .notExecuted(error: e, request: request)
            case .state:                continue
            case .unknown:              continue
            }
        }
    }
}
