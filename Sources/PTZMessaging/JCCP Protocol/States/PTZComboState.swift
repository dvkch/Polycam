//
//  PTZComboState.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZReadableCombo<Value>: PTZState where Variant == PTZNone, Value: JSONEncodable {
    init?(messages: [PTZMessage])
    static func get() -> [PTZRequest]
}

public protocol PTZWriteableCombo<Value>: PTZState where Variant == PTZNone, Value: CLIDecodable {
    init(_ value: Value)
    func set() -> [PTZRequest]
}

public extension PTZWriteableCombo {
    init?(valueString: String) {
        guard let value = Value.init(from: valueString) else { return nil }
        self.init(value)
    }
}
