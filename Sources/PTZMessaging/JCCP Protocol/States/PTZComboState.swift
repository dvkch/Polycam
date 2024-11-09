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

public extension PTZReadableCombo {
    static var cliReadDescription: String {
        return name.prefix(1).lowercased() + name.dropFirst()
    }
}

public extension PTZWriteableCombo {
    static var cliWriteDescription: String {
        var description: String = name.prefix(1).lowercased() + name.dropFirst()
        if !Value.cliStringExamples.isEmpty {
            description += "=" + Value.cliStringExamples.joined(separator: "/")
        }
        return description
    }
}
