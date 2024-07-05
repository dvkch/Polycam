//
//  File.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation

class Camera: Loggable {
    
    // MARK: Init
    init(serial: Serial) {
        self.serial = serial
    }
    
    deinit {
        stop()
    }
    
    // MARK: Properties
    private let serial: Serial
    var logLevel: LogLevel = .debug
    var logTag: String = "Camera"

    // MARK: Actions
    @discardableResult
    func sendRequest(_ request: PTZRequest, replyTimeout: TimeInterval = 1) -> [any PTZReply] {
        log(.info, request.description)
        log(.debug, "> \(request.bytes.stringRepresentation)")
        serial.sendBytes(request.bytes)
        
        let startDate = Date()
        var bytes = Bytes()
        var justReceivedBytes = false

        while Date().timeIntervalSince(startDate) < replyTimeout && (bytes.isEmpty || justReceivedBytes) {
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

        return replies
    }
    
    func stop() {
        serial.stop()
    }
}
