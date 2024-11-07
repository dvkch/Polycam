//
//  Camera.swift
//  
//
//  Created by syan on 25/06/2024.
//

import Foundation
import PTZCommon
import PTZMessaging

public typealias CameraError = DeviceError

public class Camera: Device {}

// MARK: Actions
public extension Camera {
    func powerOnIfNeeded() {
        if power == .on {
            return
        }
        powerOnIfNeeded()
    }

    func powerOn() {
        log(.info, "Starting boot sequence...")

        power = .on
        while hello == nil {
            Thread.sleep(forTimeInterval: 0.05)
        }
        devMode = true
        mire = false
        greyscale = false
        led = .init(color: .default, mode: .default)
        ledIntensity = .init(r: .default, g: .default, b: .default)
        videoOutput = .default
        shutterSpeed = .default
        inverted = false
        autoFocus = true
        whiteBalance = .default
        gainMode = .default
        gainRed = .default
        gainBlue = .default
        brightness = .default
        saturation = .default
        backlightCompensation = false

        log(.info, "Finished boot sequence")
    }
        
    func powerOff() {
        try? set(PTZLedState(.init(color: .off, mode: .off)))
        try? set(PTZPowerState(.standby))

        /*
        while serial.readAllBytes() != [0x00] {
            Thread.sleep(forTimeInterval: 0.1)
        }
         */
    }
}

// MARK: Colors
public extension Camera {
    var brightness: PTZBrightness {
        get { try! get(PTZBrightnessState.self, rescueModeCondition: true) }
        set { try! set(PTZBrightnessState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var calibration: PTZCalibrationMatrix {
        get { try! get(PTZCalibrationMatrixState.self) }
        set { try! set(PTZCalibrationMatrixState(newValue)) }
    }
    
    var contrast: PTZContrast {
        get { try! get(PTZContrastState.self, rescueModeCondition: true) }
        set { try! set(PTZContrastState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var saturation: PTZSaturation {
        get { try! get(PTZSaturationState.self, rescueModeCondition: true) }
        set { try! set(PTZSaturationState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var sharpness: PTZSharpness {
        get { try! get(PTZSharpnessState.self, rescueModeCondition: true) }
        set { try! set(PTZSharpnessState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var whiteBalance: PTZWhiteBalance {
        get { try! get(PTZWhiteBalanceState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    func calibrateWhiteBalance() {
        try! set(PTZWhiteBalanceCalibrationAction(), rescueModeCondition: true)
    }
    
    var whiteBalanceTemp: PTZWhiteBalanceTemp {
        get { try! get(PTZWhiteBalanceTempState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceTempState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var whiteBalanceTint: PTZWhiteBalanceTint {
        get { try! get(PTZWhiteBalanceTintState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceTintState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var whiteLevel: PTZWhiteLevel {
        get { try! get(PTZWhiteLevelState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteLevelState(newValue), debounce: true, rescueModeCondition: true) }
    }
}

// MARK: Functions
public extension Camera {
    subscript(clock: PTZClock) -> UInt32 {
        get { try! get(PTZClockState.self, for: clock, rescueModeCondition: true) }
        set { try! set(PTZClockState(newValue, for: clock), debounce: true, rescueModeCondition: true) }
    }
    
    var devMode: Bool {
        get { try! get(PTZDevModeState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZDevModeState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    func drunkTest() {
        try! set(PTZDrunkTestAction(), rescueModeCondition: true)
    }
    
    var drunkTestPhase: PTZDrunkTestPhase {
        try! get(PTZDrunkTestPhaseState.self, rescueModeCondition: true)
    }
    
    var hello: PTZHello? {
        try? get(PTZHelloState.self, rescueModeCondition: true)
    }
    
    var led: PTZLed {
        get { try! get(PTZLedState.self, rescueModeCondition: true) }
        set { try! set(PTZLedState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var ledIntensity: PTZLedIntensity {
        get { try! get(PTZLedIntensityState.self, rescueModeCondition: true) }
        set { try! set(PTZLedIntensityState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var power: PTZPower {
        get { try! get(PTZPowerState.self, rescueModeCondition: true) }
        set { try! set(PTZPowerState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    func reset(_ reset: PTZReset) {
        try! set(PTZResetAction(reset), rescueModeCondition: true)
    }
    
    var sleepTimeout: PTZSleepTimeout {
        get { try! get(PTZSleepTimeoutState.self, rescueModeCondition: true) }
        set { try! set(PTZSleepTimeoutState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    func statistics(_ group: PTZStatisticsGroup) -> PTZStatisticsValues {
        try! get(PTZStatisticsState.self, for: group, rescueModeCondition: true)
    }
}

// MARK: Image quality
public extension Camera {
    var greyscale: Bool {
        get { try! get(PTZGreyscaleState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZGreyscaleState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }

    var inverted: Bool {
        get { try! get(PTZInvertedState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZInvertedState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var mire: Bool {
        get { try! get(PTZMireState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZMireState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var noiseReduction: Bool {
        get { try! get(PTZNoiseReductionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZNoiseReductionState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var sensorSmoothing: Bool {
        get { try! get(PTZNoiseReductionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZNoiseReductionState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }

    var videoOutput: PTZVideoOutput {
        get { try! get(PTZVideoOutputState.self, rescueModeCondition: true) }
        set { try! set(PTZVideoOutputState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var vignetteCorrection: Bool {
        get { try! get(PTZVignetteCorrectionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZVignetteCorrectionState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
}

// MARK: Light
public extension Camera {
    var autoExposure: Bool {
        get { try! get(PTZAutoExposureState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZAutoExposureState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var backlightCompensation: Bool {
        get { try! get(PTZBacklightCompensationState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZBacklightCompensationState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var gainMode: PTZGainMode {
        get { try! get(PTZGainModeState.self, rescueModeCondition: true) }
        set { try! set(PTZGainModeState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var gainRed: PTZColorGain {
        get { try! get(PTZGainRedState.self, rescueModeCondition: true) }
        set { try! set(PTZGainRedState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var gainBlue: PTZColorGain {
        get { try! get(PTZGainBlueState.self, rescueModeCondition: true) }
        set { try! set(PTZGainBlueState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var effectiveGain: PTZGainEffective {
        try! get(PTZGainEffectiveState.self, rescueModeCondition: true)
    }
    
    var irisLevel: PTZIrisLevel {
        get { try! get(PTZIrisLevelState.self, rescueModeCondition: true) }
        set { try! set(PTZIrisLevelState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var shutterSpeed: PTZShutterSpeed {
        get { try! get(PTZShutterSpeedState.self, rescueModeCondition: true) }
        set { try! set(PTZShutterSpeedState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var wideDynamicRange: Bool {
        get { try! get(PTZWideDynamicRangeState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZWideDynamicRangeState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
}

// MARK: Position
public extension Camera {
    var autoFocus: Bool {
        get { try! get(PTZAutoFocusState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZAutoFocusState(.init(rawValue: newValue)), debounce: true, rescueModeCondition: true) }
    }
    
    var focus: PTZFocus {
        get { try! get(PTZFocusState.self, rescueModeCondition: true) }
        set { try! set(PTZFocusState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    func startFocus() {
        try! set(PTZFocusAction(), rescueModeCondition: true)
    }

    func movePan(_ direction: PTZPanDirection, speed: PTZPanSpeed) {
        try! set(PTZMovePanAction(speed, for: direction), rescueModeCondition: true)
    }
    
    func moveTilt(_ direction: PTZTiltDirection, speed: PTZTiltSpeed) {
        try! set(PTZMoveTiltAction(speed, for: direction), rescueModeCondition: true)
    }
    
    func moveFocus(_ direction: PTZFocusDirection, speed: PTZFocusSpeed) {
        try! set(PTZMoveFocusAction(speed, for: direction), rescueModeCondition: true)
    }
    
    func moveZoom(_ direction: PTZZoomDirection, speed: PTZZoomSpeed) {
        try! set(PTZMoveZoomAction(speed, for: direction), rescueModeCondition: true)
    }
    
    var pan: PTZPan {
        get { try! get(PTZPanState.self, rescueModeCondition: true) }
        set { try! set(PTZPanState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var position: PTZPosition {
        get { try! get(PTZPositionState.self, rescueModeCondition: true) }
        set { try! set(PTZPositionState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    subscript(preset: PTZPreset) -> PTZPosition {
        get { try! get(PTZPresetState.self, for: preset, rescueModeCondition: true) }
        set { try! set(PTZPresetState(newValue, for: preset), debounce: true, rescueModeCondition: true) }
    }
    
    var tilt: PTZTilt {
        get { try! get(PTZTiltState.self, rescueModeCondition: true) }
        set { try! set(PTZTiltState(newValue), debounce: true, rescueModeCondition: true) }
    }
    
    var zoom: PTZZoom {
        get { try! get(PTZZoomState.self, rescueModeCondition: true) }
        set { try! set(PTZZoomState(newValue), debounce: true, rescueModeCondition: true) }
    }
}
