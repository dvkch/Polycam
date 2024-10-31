//
//  AutoFocus.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZAutoFocusState: PTZSingleValueState {
    static var name: String = "AutoFocus"
    static var register: (UInt8, UInt8) = (0x02, 0x09)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }

    var waitingTimeIfExecuted: TimeInterval { 1 } // needs a bit of time before allowing manual focus, or might reply "mode condition"
}
