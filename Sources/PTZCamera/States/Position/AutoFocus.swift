//
//  AutoFocus.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

internal struct PTZAutoFocusState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "AutoFocus"
    static var register: (UInt8, UInt8) = (0x02, 0x09)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    func set() -> PTZRequest {
        // needs a bit of time before allowing manual focus, or might reply "mode condition"
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 1)
    }
}
