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

public class Camera: Device {
    
    // MARK: Init
    public init(serial: SerialName, logLevel: LogLevel, powerOffAfterUse: Bool) throws(CameraError) {
        self.powerOffAfterUse = powerOffAfterUse
        try super.init(serial: serial, logLevel: logLevel)

        self.powerOn()
    }
    
    deinit {
        if powerOffAfterUse {
            powerOff()
        }
    }
    
    // MARK: Properties
    private let powerOffAfterUse: Bool
}

// MARK: Actions
public extension Camera {
    internal func powerOn() {
        let sequence: [any PTZReadable & PTZWriteable] = [
            PTZDevModeState(.on),
            PTZMireState(.off),
            PTZColorsState(.on),
            PTZLedState(.init(color: .default, mode: .default)),
            PTZLedIntensityState(.init(r: .default, g: .default, b: .default)),
            PTZVideoOutputState(.default),
            PTZShutterSpeedState(.default),
            PTZInvertedState(.off),
            PTZAutoFocusState(.on),
            PTZWhiteBalanceState(.default),
            PTZGainModeState(.default),
            PTZRedGainState(.default),
            PTZBlueGainState(.default),
            PTZBrightnessState(.default),
            PTZSaturationState(.default),
            PTZBacklightCompensationState(.off),
        ]

        log(.info, "Starting boot sequence...")
        try? set(PTZPowerState(.on))

        var hello: PTZHello? = nil
        while hello == nil {
            hello = try? get(PTZHelloState.self)
        }

        for state in sequence {
            try! set(state, debounce: true)
        }
        log(.info, "Finished boot sequence")
    }
        
    internal func powerOff() {
        try? set(PTZLedState(.init(color: .off, mode: .off)))
        try? set(PTZPowerState(.standby))

        /*
        while serial.readAllBytes() != [0x00] {
            Thread.sleep(forTimeInterval: 0.1)
        }
         */
    }
}

// MARK: States
#warning("Define a macro that would register those + create those extensions")
#warning("group states by kind in folders, registration and camera extension")
// MARK: Colors
public extension Camera {
    var brightness: PTZBrightness {
        get { try! get(PTZBrightnessState.self, rescueModeCondition: true) }
        set { try! set(PTZBrightnessState(newValue), rescueModeCondition: true) }
    }
    
    var calibration: PTZCalibrationMatrix {
        get { try! get(PTZCalibrationMatrixState.self) }
        set { try! set(PTZCalibrationMatrixState(newValue)) }
    }
    
    var contrast: PTZContrast {
        get { try! get(PTZContrastState.self, rescueModeCondition: true) }
        set { try! set(PTZContrastState(newValue), rescueModeCondition: true) }
    }
    
    var saturation: PTZSaturation {
        get { try! get(PTZSaturationState.self, rescueModeCondition: true) }
        set { try! set(PTZSaturationState(newValue), rescueModeCondition: true) }
    }
    
    var sharpness: PTZSharpness {
        get { try! get(PTZSharpnessState.self, rescueModeCondition: true) }
        set { try! set(PTZSharpnessState(newValue), rescueModeCondition: true) }
    }
    
    var whiteBalance: PTZWhiteBalance {
        get { try! get(PTZWhiteBalanceState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceState(newValue), rescueModeCondition: true) }
    }
    
    func calibrateWhiteBalance() {
        try! set(PTZWhiteBalanceCalibrationAction(), rescueModeCondition: true)
    }
    
    var whiteBalanceTemp: PTZWhiteBalanceTemp {
        get { try! get(PTZWhiteBalanceTempState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceTempState(newValue), rescueModeCondition: true) }
    }
    
    var whiteBalanceTint: PTZWhiteBalanceTint {
        get { try! get(PTZWhiteBalanceTintState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteBalanceTintState(newValue), rescueModeCondition: true) }
    }
    
    var whiteLevel: PTZWhiteLevel {
        get { try! get(PTZWhiteLevelState.self, rescueModeCondition: true) }
        set { try! set(PTZWhiteLevelState(newValue), rescueModeCondition: true) }
    }
}

// MARK: Functions
public extension Camera {
    subscript(clock: PTZClock) -> UInt32 {
        get { try! get(PTZClockState.self, for: clock, rescueModeCondition: true) }
        set { try! set(PTZClockState(newValue, for: clock), rescueModeCondition: true) }
    }
    
    var devMode: Bool {
        get { try! get(PTZDevModeState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZDevModeState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    func drunkTest() {
        try! set(PTZDrunkTestAction(), rescueModeCondition: true)
    }
    
    var drunkTestPhase: PTZDrunkTestPhase {
        try! get(PTZDrunkTestPhaseState.self, rescueModeCondition: true)
    }
    
    var hello: PTZHello {
        try! get(PTZHelloState.self, rescueModeCondition: true)
    }
    
    var led: PTZLed {
        get { try! get(PTZLedState.self, rescueModeCondition: true) }
        set { try! set(PTZLedState(newValue), rescueModeCondition: true) }
    }
    
    var ledIntensity: PTZLedIntensity {
        get { try! get(PTZLedIntensityState.self, rescueModeCondition: true) }
        set { try! set(PTZLedIntensityState(newValue), rescueModeCondition: true) }
    }
    
    var power: PTZPower {
        get { try! get(PTZPowerState.self, rescueModeCondition: true) }
        set { try! set(PTZPowerState(newValue), rescueModeCondition: true) }
    }
    
    func reset(_ reset: PTZReset) {
        try! set(PTZResetAction(reset), rescueModeCondition: true)
    }
    
    var sleepTimeout: PTZSleepTimeout {
        get { try! get(PTZSleepTimeoutState.self, rescueModeCondition: true) }
        set { try! set(PTZSleepTimeoutState(newValue), rescueModeCondition: true) }
    }
    
    func statistics(_ group: PTZStatisticsGroup) -> PTZStatisticsValues {
        try! get(PTZStatisticsState.self, for: group, rescueModeCondition: true)
    }
}

// MARK: Image quality
public extension Camera {
    var greyscale: Bool {
        get { try! get(PTZGreyscaleState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZGreyscaleState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }

    var inverted: Bool {
        get { try! get(PTZInvertedState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZInvertedState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var mire: Bool {
        get { try! get(PTZMireState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZMireState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var noiseReduction: Bool {
        get { try! get(PTZNoiseReductionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZNoiseReductionState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var sensorSmoothing: Bool {
        get { try! get(PTZNoiseReductionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZNoiseReductionState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }

    var videoOutput: PTZVideoOutput {
        get { try! get(PTZVideoOutputState.self, rescueModeCondition: true) }
        set { try! set(PTZVideoOutputState(newValue), rescueModeCondition: true) }
    }
    
    var vignetteCorrection: Bool {
        get { try! get(PTZVignetteCorrectionState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZVignetteCorrectionState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
}

// MARK: Light
public extension Camera {
    var autoExposure: Bool {
        get { try! get(PTZAutoExposureState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZAutoExposureState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var backlightCompensation: Bool {
        get { try! get(PTZBacklightCompensationState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZBacklightCompensationState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var gainMode: PTZGainMode {
        get { try! get(PTZGainModeState.self, rescueModeCondition: true) }
        set { try! set(PTZGainModeState(newValue), rescueModeCondition: true) }
    }
    
    var redGain: PTZColorGain {
        get { try! get(PTZRedGainState.self, rescueModeCondition: true) }
        set { try! set(PTZRedGainState(newValue), rescueModeCondition: true) }
    }
    
    var blueGain: PTZColorGain {
        get { try! get(PTZBlueGainState.self, rescueModeCondition: true) }
        set { try! set(PTZBlueGainState(newValue), rescueModeCondition: true) }
    }
    
    var effectiveGain: PTZEffectiveGain {
        try! get(PTZEffectiveGainState.self, rescueModeCondition: true)
    }
    
    var irisLevel: PTZIrisLevel {
        get { try! get(PTZIrisLevelState.self, rescueModeCondition: true) }
        set { try! set(PTZIrisLevelState(newValue), rescueModeCondition: true) }
    }
    
    var shutterSpeed: PTZShutterSpeed {
        get { try! get(PTZShutterSpeedState.self, rescueModeCondition: true) }
        set { try! set(PTZShutterSpeedState(newValue), rescueModeCondition: true) }
    }
    
    var wideDynamicRange: Bool {
        get { try! get(PTZWideDynamicRangeState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZWideDynamicRangeState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
}

// MARK: Position
public extension Camera {
    var autoFocus: Bool {
        get { try! get(PTZAutoFocusState.self, rescueModeCondition: true).rawValue }
        set { try! set(PTZAutoFocusState(.init(rawValue: newValue)), rescueModeCondition: true) }
    }
    
    var focus: PTZFocus {
        get { try! get(PTZFocusState.self, rescueModeCondition: true) }
        set { try! set(PTZFocusState(newValue), rescueModeCondition: true) }
    }
    
    func startFocus() {
        try! set(PTZFocusAction(), rescueModeCondition: true)
    }

    func movePan(_ direction: PTZPanDirection, speed: PTZPanTiltSpeed) {
        try! set(PTZMovePanAction(speed, for: direction), rescueModeCondition: true)
    }
    
    func moveTilt(_ direction: PTZTiltDirection, speed: PTZPanTiltSpeed) {
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
        set { try! set(PTZPanState(newValue), rescueModeCondition: true) }
    }
    
    var position: PTZPosition {
        get { try! get(PTZPositionState.self, rescueModeCondition: true) }
        set { try! set(PTZPositionState(newValue), rescueModeCondition: true) }
    }
    
    subscript(preset: PTZPreset) -> PTZPosition {
        get { try! get(PTZPresetState.self, for: preset, rescueModeCondition: true) }
        set { try! set(PTZPresetState(newValue, for: preset), rescueModeCondition: true) }
    }
    
    var tilt: PTZTilt {
        get { try! get(PTZTiltState.self, rescueModeCondition: true) }
        set { try! set(PTZTiltState(newValue), rescueModeCondition: true) }
    }
    
    var zoom: PTZZoom {
        get { try! get(PTZZoomState.self, rescueModeCondition: true) }
        set { try! set(PTZZoomState(newValue), rescueModeCondition: true) }
    }
}
