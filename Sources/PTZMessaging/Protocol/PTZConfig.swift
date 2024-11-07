//
//  PTZConfig.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

public struct PTZConfig {
    public static private(set) var knownStates: [any PTZState.Type] = []

    public static var knownReadableStates: [any PTZReadable.Type] {
        knownStates.compactMap { $0 as? (any PTZReadable.Type) }
    }
    
    public static var knownReadableCombosStates: [any PTZReadableCombo.Type] {
        knownStates.compactMap { $0 as? (any PTZReadableCombo.Type) }
    }
    
    public static var knownWriteableStates: [any PTZWriteable.Type] {
        knownStates.compactMap { $0 as? (any PTZWriteable.Type) }
    }
    
    public static var knownWriteableComboStates: [any PTZWriteableCombo.Type] {
        knownStates.compactMap { $0 as? (any PTZWriteableCombo.Type) }
    }

    public static func register(_ state: any PTZState.Type) {
        for knownState in knownStates {
            if knownState.name == state.name {
                if knownState == state {
                    return
                }
                print("Warning: registering a new state (\(state)) with the same name as an existing one (\(knownState)).")
            }
        }
        knownStates.append(state)
    }
}
