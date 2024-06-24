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
    
    // MARK: Properties
    private let serial: Serial
    var logLevel: LogLevel = .debug
    var logTag: String = "Camera"

    // MARK: Actions
    @discardableResult
    func sendRequest(_ request: PTZRequest, replyTimeout: TimeInterval = 1) -> [PTZReplyParsed] {
        log(.info, "Request: \(request)")
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
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        log(.debug, "Reply: \(bytes.stringRepresentation)")

        let replies = PTZReply(bytes: bytes).replies()
        log(.info, "Replies: \(replies)")

        return replies
    }
}
