//
//  PTZConfig.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

public struct PTZConfig {
    public static private(set) var knownStates: [any PTZState.Type] = []

    public static func register(_ state: any PTZState.Type) {
        for knownState in knownStates {
            if knownState == state {
                return
            }
        }
        knownStates.append(state)
    }
}
