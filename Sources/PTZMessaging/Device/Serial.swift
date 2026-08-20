//
//  Serial.swift
//  PTZ
//
//  Created by syan on 09/01/2024.
//

import Foundation
import SwiftSerial

internal final class Serial: Loggable {
    
    // MARK: Init
    internal init(device: SerialName, tag: String, logLevel: LogLevel) throws(PortError) {
        self.device = device
        self.logLevel = logLevel
        self.logTag = "Serial \(tag)"
        try open()
    }
    
    // MARK: Properties
    internal let device: SerialName
    internal var logLevel: LogLevel
    internal let logTag: String
    private(set) var isOpen: Bool = false
    private(set) var port: SerialPort!

    // MARK: Serial
    private func open() throws(PortError) {
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
    }

    // MARK: Outside world
    internal func sendBytes(_ bytes: Bytes) {
        guard bytes.count > 0 else { return }

        do {
            let writtenBytes = try port.writeData(Data(bytes))
            log(.debug, "Wrote \(writtenBytes) out of \(bytes.count) bytes: \(bytes.hexString)")
        }
        catch {
            log(.error, "Error writing: \(error)")
        }
    }

    /// Synchronously reads whatever is currently available on the port. Given VMIN=0/VTIME=1,
    /// this returns promptly once data has arrived, and blocks up to ~0.1s otherwise.
    internal func readAvailableBytes() -> Bytes {
        guard let data = try? port.readData(ofLength: 1024), !data.isEmpty else {
            return []
        }
        return Bytes(data)
    }

    internal func stop() {
        guard isOpen else { return }

        port.closePort()
        isOpen = false
        log(.info, "Closed port")
    }
}
