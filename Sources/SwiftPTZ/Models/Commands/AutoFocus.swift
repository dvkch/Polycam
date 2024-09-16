//
//  AutoFocus.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZRequestSetAutoFocus: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x42, 0x09], enabled) }
    var description: String { "Set auto focus \(enabled)" }
    var waitingTimeIfExecuted: TimeInterval { 1 } // needs a bit of time before allowing manual focus, or might reply "mode condition"
}

struct PTZRequestGetAutoFocus: PTZGetRequest {
    typealias Reply = PTZReplyAutoFocus
    var bytes: Bytes { buildBytes([0x02, 0x09]) }
    var description: String { "Get auto focus" }
}

struct PTZReplyAutoFocus: PTZReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x09]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "AutoFocus(\(enabled))"
    }
}
