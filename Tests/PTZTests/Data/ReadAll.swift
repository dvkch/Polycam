//
//  ReadAll.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

struct ReadAll: Codable {
    let device: String

    // MARK: Colors
    let brightness: ReadValue<Int>
    let calibrationHue: [String: ReadValue<Int>]
    let calibrationLuminance: [String: ReadValue<Int>]
    let calibrationSaturation: [String: ReadValue<Int>]
    let calibrationMatrix: ReadValue<[String: [Int]]>
    let contrast: ReadValue<Int>
    let saturation: ReadValue<Int>
    let sharpness: ReadValue<Int>
    let whiteBalance: ReadValue<Int>
    let whiteBalanceTemp: ReadValue<Int>
    let whiteBalanceTint: ReadValue<Int>
    let whiteLevel: ReadValue<Int>
    
    // MARK: Function
    let clock: [String: ReadValue<UInt32>]
    let devMode: ReadValue<Bool>
    let drunkTestPhase: ReadValue<Int>
    let hello: ReadValue<[String: String]>
    let led: ReadValue<[String: Int]>
    let ledIntensity: ReadValue<[String: Int]>
    let power: ReadValue<Int>
    let sleepTimeout: ReadValue<Int>
    let statistics: [String: ReadValue<[Int]>]
    
    // MARK: Image
    let greyscale: ReadValue<Bool>
    let inverted: ReadValue<Bool>
    let mire: ReadValue<Bool>
    let noiseReduction: ReadValue<Bool>
    let sensorSmoothing: ReadValue<Bool>
    let videoOutput: ReadValue<Int>
    let vignetteCorrection: ReadValue<Bool>
    
    // MARK: Light
    let autoExposure: ReadValue<Bool>
    let backlightCompensation: ReadValue<Bool>
    let colorGain: [String: ReadValue<Int>]
    let effectiveGain: ReadValue<Int>
    let gainMode: ReadValue<Int>
    let irisLevel: ReadValue<Int>
    let shutterSpeed: ReadValue<Int>
    let wideDynamicRange: ReadValue<Bool>

    // MARK: Position
    let autoFocus: ReadValue<Bool>
    let focus: ReadValue<Int>
    let pan: ReadValue<Int>
    let position: ReadValue<[String: Int]>
    let preset: [String: ReadValue<[String: Int]>]
    let tilt: ReadValue<Int>
    let zoom: ReadValue<Int>
}
