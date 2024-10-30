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
    init(device: SerialName, tag: String, logLevel: LogLevel) throws(PortError) {
        self.device = device
        self.logLevel = logLevel
        self.logTag = "Serial \(tag)"
        try open()
    }
    
    // MARK: Properties
    let device: SerialName
    var logLevel: LogLevel
    let logTag: String
    private(set) var isOpen: Bool = false
    private(set) var port: SerialPort!
    private let lock = NSLock()
    private var readBytes: Bytes = []

    // MARK: Serial
    private func open() throws(PortError) {
        lock.lock()
        defer { lock.unlock() }

        guard !isOpen else { return }

        log(.info, "Opening port...")
        port = SerialPort(path: device.rawValue)
        do {
            try port.openPort()
            try port.setSettings(
                baudRateSetting: .symmetrical(.baud9600),
                minimumBytesToRead: 0,
                timeout: 1, /* 0 means wait indefinitely */
                parityType: .even,
                sendTwoStopBits: false, /* 1 stop bit is the default */
                dataBitsSize: .bits8,
                useHardwareFlowControl: false,
                useSoftwareFlowControl: false,
                processOutput: false
                
            )
        }
        catch {
            throw error as! PortError
        }
        isOpen = true
        log(.info, "> opened!")
        
        Task {
            for await data in (try port.asyncData()) {
                lock.withLock {
                    readBytes.append(contentsOf: data)
                }
            }
        }
        log(.info, "> started reading bytes")
    }
    
    // MARK: Outside world
    func sendBytes(_ bytes: Bytes, lastTransmission: Bool = false) {
        lock.lock()
        defer { lock.unlock() }

        guard bytes.count > 0 else { return }

        do {
            readBytes.removeAll()
            let writtenBytes = try port.writeData(Data(bytes))
            if bytes.count > 0 {
                log(.debug, "Wrote \(writtenBytes) out of \(bytes.count) bytes: \(bytes.hexString)")
            }
        }
        catch {
            log(.error, "Error writing: \(error)")
        }
    }
    
    func readAllBytes() -> Bytes {
        lock.withLock {
            let bytes = self.readBytes
            self.readBytes.removeAll()
            return bytes
        }
    }
    
    func stop() {
        lock.lock()
        defer { lock.unlock() }

        guard isOpen else { return }

        port.closePort()
        isOpen = false
        log(.info, "Closed port")
    }
}
