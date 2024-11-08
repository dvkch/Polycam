//
//  Position.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZPosition: Equatable, CustomStringConvertible, CLIDecodable, JSONEncodable {
    public var pan: PTZPan
    public var tilt: PTZTilt
    public var zoom: PTZZoom
    
    public init(pan: PTZPan, tilt: PTZTilt, zoom: PTZZoom) {
        self.pan = pan
        self.tilt = tilt
        self.zoom = zoom
    }
    
    public static func random() -> Self {
        .init(pan: .random, tilt: .random, zoom: .random)
    }
    
    public init?(from cliString: String) {
        let parts = cliString.split(separator: ",")
        guard parts.count == 3 else { return nil }
        
        guard let pan = PTZPan(from: String(parts[0])), let tilt = PTZTilt(from: String(parts[1])), let zoom = PTZZoom(from: String(parts[2])) else { return nil }
        self.pan = pan
        self.tilt = tilt
        self.zoom = zoom
    }
    
    public var description: String { "\(pan), \(tilt), \(zoom)" }
    public var toJSON: JSONValue {
        return ["pan": pan.toJSON, "tilt": tilt.toJSON, "zoom": zoom.toJSON]
    }
}

/// Sets and reads the current position, pan tilt and zoom in one go.
/// Discovered in the original program's logs
public struct PTZPositionState: PTZReadable, PTZWritable {
    public static let name: String = "Position"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x50)
    public var value: PTZPosition
    
    public init(_ value: PTZPosition, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register.set()) else { return nil }
        self.value = .init(
            pan:  message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            tilt: message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            zoom: message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
        )
    }
    
    public func setMessage() -> PTZMessage {
        return .init(
            Self.register.set(regOffset: 1),
            PTZArgument(value.pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(value.tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(value.zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZUInt(rawValue: 0x03), .raw8(10))
        )
    }
}
