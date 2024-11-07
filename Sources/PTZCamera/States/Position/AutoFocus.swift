//
//  AutoFocus.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

/// Controls the ability to focus manually or automatically.
/// Discovered by fuzzing
public struct PTZAutoFocusState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "AutoFocus"
    public static var register: (UInt8, UInt8) = (0x02, 0x09)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        // needs a bit of time before allowing manual focus, or might reply "mode condition"
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 1)
    }
}
