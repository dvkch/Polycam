//
//  Position.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZPosition: Equatable, CustomStringConvertible {
    var pan: PTZPan
    var tilt: PTZTilt
    var zoom: PTZZoom
    
    var description: String { "\(pan), \(tilt), \(zoom)" }
}

struct PTZPositionState: PTZInvariantState {
    static var name: String = "Position"
    static var register: (UInt8, UInt8) = (0x01, 0x50)
    var value: PTZPosition
    
    init(_ value: PTZPosition) {
        self.value = value
    }
    
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = .init(
            pan:  message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            tilt: message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            zoom: message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
        )
    }
    
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: .init(
            Self.setRegister,
            PTZArgument(value.pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(value.tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(value.zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZUInt(rawValue: 0x03), .raw8(10))
        ))
    }
}
