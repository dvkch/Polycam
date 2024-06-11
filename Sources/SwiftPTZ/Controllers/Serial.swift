//
//  Serial.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import SwiftSerial

class Serial {

    private let tag: String
    private let delay: TimeInterval
    init(tag: String, deviceName: String, delay: TimeInterval = 0) throws {
        self.tag = tag
        self.delay = delay

        try open(deviceName: deviceName)

        readQueue.async {
            self.readLoop()
        }
        writeQueue.async {
            self.writeLoop()
        }
    }
    
    private(set) var port: SerialPort!
    private func open(deviceName: String) throws {
        Log.w(tag: tag, message: "Opening port...")
        
        self.port = SerialPort(path: deviceName)
        self.port.setSettings(
            receiveRate: .baud9600,
            transmitRate: .baud9600,
            minimumBytesToRead: 1,
            timeout: 10, /* 0 means wait indefinitely */
            parityType: .even,
            sendTwoStopBits: false, /* 1 stop bit is the default */
            dataBitsSize: .bits8,
            useHardwareFlowControl: false,
            useSoftwareFlowControl: false,
            processOutput: false

        )
        try self.port.openPort()

        Log.w(tag: tag, message: "> opened!")
    }
    
    private var shouldStop: Bool = false
    func stop() {
        shouldStop = true
    }

    private var receivedByteTimeoutTimer: Timer = Timer() {
        didSet {
            oldValue.invalidate()
            RunLoop.current.add(receivedByteTimeoutTimer, forMode: .common)
        }
    }
    private var receivedLastByteDate: Date = Date(timeIntervalSince1970: 0) {
        didSet {
            let startingNewMessage = Date().timeIntervalSince(oldValue) > 0.01
            if startingNewMessage {
                flushReceivedBytesToConsole()
            }
        }
    }
    private var receivedBytes: [UInt8] = [] {
        didSet {
            let date = receivedLastByteDate
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2 + delay) { [weak self] in
                if date == self?.receivedLastByteDate {
                    self?.flushReceivedBytesToConsole()
                }
            }
        }
    }
    @objc private func flushReceivedBytesToConsole() {
        if !receivedBytes.isZero {
            Log.w(tag: tag, message: "> \(receivedBytes.stringRepresentation)")
        }
        receivedBytes = []
    }

    private func readLoop() {
        Log.w(tag: tag, message: "Reading...")
        do {
            while !shouldStop {
                let byte = try port.readByte()
                receivedLastByteDate = Date()
                receivedBytes.append(byte)
            }
        }
        catch {
            Log.w(tag: tag, message: "Error reading: \(error)")
        }
    }
    private func writeLoop() {
        do {
            while !shouldStop {
                let bytes = writeLock.locking {
                    defer { bytesToSend = [] }
                    return bytesToSend
                }

                for byte in bytesToSend {
                    try _ = port.writeData(Data([byte]))
                }
                if bytes.count > 0 {
                    print("Wrote \(bytes.count) bytes: \(bytes.stringRepresentation)")
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        catch {
            Log.w(tag: tag, message: "Error writing: \(error)")
        }
    }
    
    private let writeLock = NSLock()
    private let writeQueue = DispatchQueue.global(qos: .userInteractive)
    private var bytesToSend: [UInt8] = []
    func sendBytes(_ bytes: [UInt8]) {
        writeLock.locking {
            bytesToSend.append(contentsOf: bytes)
        }
    }
    
    private let readQueue = DispatchQueue.global(qos: .userInteractive)
    private var readBytes: [UInt8] = []
    func readByte() -> UInt8 {
        var byte: UInt8 = 0
        readQueue.sync {
            if !readBytes.isEmpty {
                byte = readBytes.removeFirst()
            }
        }
        return byte
    }
}
