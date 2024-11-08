//
//  PTZCalibrationMatrix+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

@testable import PTZCamera

extension PTZCalibrationMatrix {
    static func random() -> Self {
        var matrix = self.init()
        for range in PTZCalibrationRange.allCases {
            matrix[hue: range]        = .allCases.randomElement()!
            matrix[luminance: range]  = .allCases.randomElement()!
            matrix[saturation: range] = .allCases.randomElement()!
        }
        return matrix
    }
}
