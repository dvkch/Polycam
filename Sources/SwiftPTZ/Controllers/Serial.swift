//
//  Serial.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import SwiftSerial

class Serial: Loggable {
    
    // MARK: Init
    init(tag: String, name: SerialName) throws {
        self.logTag = "Serial \(tag)"
        try open(deviceName: name.rawValue)
        
        readQueue.async {
            self.readLoop()
        }
        writeQueue.async {
            self.writeLoop()
        }
    }
    
    // MARK: Properties
    var logLevel: LogLevel = .debug
    let logTag: String
    private(set) var port: SerialPort!
    private var shouldStop: Bool = false
    private let writeLock = NSLock()
    private let writeQueue = DispatchQueue.global(qos: .userInteractive)
    private var bytesToSend: [UInt8] = []
    private let readLock = NSLock()
    private let readQueue = DispatchQueue.global(qos: .userInteractive)
    private var readBytes: [UInt8] = []
    private var lastReadUUID = UUID()

    // MARK: Serial
    private func open(deviceName: String) throws {
        log(.info, "Opening port...")
        
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
        
        log(.info, "> opened!")
    }
    
    // MARK: Read/Write loops
    private func readLoop() {
        log(.info, "Starting read loop...")
        
        do {
            while !shouldStop {
                let readUUID = UUID()
                let byte = try port.readByte()
                readLock.withLock {
                    self.lastReadUUID = readUUID
                    self.readBytes.append(byte)
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                        guard self.lastReadUUID == readUUID else { return }
                        self.readLock.withLock {
                            self.log(.debug, "Received \(self.readBytes.count) bytes: \(self.readBytes.stringRepresentation)")
                        }
                    }
                }
            }
        }
        catch {
            log(.error, "Error reading: \(error)")
        }
    }
    
    private func writeLoop() {
        log(.info, "Starting write loop...")
        
        do {
            while !shouldStop {
                let bytes = writeLock.withLock {
                    defer { bytesToSend = [] }
                    return bytesToSend
                }
                
                let writtenBytes = try port.writeData(Data(bytes))
                if bytes.count > 0 {
                    log(.debug, "Wrote \(writtenBytes) out of \(bytes.count) bytes: \(bytes.stringRepresentation)")
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
        catch {
            log(.error, "Error writing: \(error)")
        }
    }
    
    // MARK: Outside world
    func sendBytes(_ bytes: [UInt8]) {
        writeLock.withLock {
            bytesToSend.append(contentsOf: bytes)
        }
    }
    
    func readAllBytes() -> [UInt8] {
        return readLock.withLock {
            let bytes = Array(readBytes)
            readBytes = []
            return bytes
        }
    }
    
    func stop() {
        shouldStop = true
    }
}
