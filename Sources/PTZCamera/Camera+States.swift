//
//  Camera+States.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import PTZMessaging

@freestanding(declaration, names: arbitrary)
public macro PTZState<T: PTZState>(_ kind: StaticString, _ state: T.Type, _ variant: T.Variant.Type, _ value: T.Value.Type) = #externalMacro(module: "PTZCameraMacros", type: "PTZState")

// MARK: Registration
public extension Camera {
    static func registerKnownStates() {
        // Colors
        PTZConfig.register(PTZBrightnessState.self)
        PTZConfig.register(PTZCalibrationHueState.self)
        PTZConfig.register(PTZCalibrationLuminanceState.self)
        PTZConfig.register(PTZCalibrationMatrixState.self)
        PTZConfig.register(PTZCalibrationSaturationState.self)
        PTZConfig.register(PTZContrastState.self)
        PTZConfig.register(PTZSaturationState.self)
        PTZConfig.register(PTZSharpnessState.self)
        PTZConfig.register(PTZWhiteBalanceState.self)
        PTZConfig.register(PTZWhiteBalanceCalibrationAction.self)
        PTZConfig.register(PTZWhiteBalanceTempState.self)
        PTZConfig.register(PTZWhiteBalanceTintState.self)
        PTZConfig.register(PTZWhiteLevelState.self)

        // Function
        PTZConfig.register(PTZClockState.self)
        PTZConfig.register(PTZDevModeState.self)
        PTZConfig.register(PTZDrunkTestAction.self)
        PTZConfig.register(PTZDrunkTestPhaseState.self)
        PTZConfig.register(PTZHelloState.self)
        PTZConfig.register(PTZLedState.self)
        PTZConfig.register(PTZLedIntensityState.self)
        PTZConfig.register(PTZPowerState.self)
        PTZConfig.register(PTZResetAction.self)
        PTZConfig.register(PTZSleepTimeoutState.self)
        PTZConfig.register(PTZStatisticsState.self)

        // Image
        PTZConfig.register(PTZGreyscaleState.self)
        PTZConfig.register(PTZInvertedState.self)
        PTZConfig.register(PTZMireState.self)
        PTZConfig.register(PTZNoiseReductionState.self)
        PTZConfig.register(PTZSensorSmoothingState.self)
        PTZConfig.register(PTZVideoOutputState.self)
        PTZConfig.register(PTZVignetteCorrectionState.self)
        
        // Light
        PTZConfig.register(PTZAutoExposureState.self)
        PTZConfig.register(PTZBacklightCompensationState.self)
        PTZConfig.register(PTZColorGainState.self)
        PTZConfig.register(PTZEffectiveGainState.self)
        PTZConfig.register(PTZGainModeState.self)
        PTZConfig.register(PTZIrisLevelState.self)
        PTZConfig.register(PTZShutterSpeedState.self)
        PTZConfig.register(PTZWideDynamicRangeState.self)

        // Position
        PTZConfig.register(PTZAutoFocusState.self)
        PTZConfig.register(PTZFocusState.self)
        PTZConfig.register(PTZFocusAction.self)
        PTZConfig.register(PTZMoveFocusAction.self)
        PTZConfig.register(PTZMovePanAction.self)
        PTZConfig.register(PTZMoveTiltAction.self)
        PTZConfig.register(PTZMoveZoomAction.self)
        PTZConfig.register(PTZPanState.self)
        PTZConfig.register(PTZPositionState.self)
        PTZConfig.register(PTZPresetState.self)
        PTZConfig.register(PTZTiltState.self)
        PTZConfig.register(PTZZoomState.self)
    }
}

// MARK: Accessors
public extension Camera {
    // Colors
    #PTZState("RWD", PTZBrightnessState.self,                  PTZNone.self,               PTZBrightness.self)
    #PTZState("RWD", PTZCalibrationHueState.self,              PTZCalibrationRange.self,   PTZCalibrationHue.self)
    #PTZState("RWD", PTZCalibrationLuminanceState.self,        PTZCalibrationRange.self,   PTZCalibrationLuminance.self)
    #PTZState("RW" , PTZCalibrationMatrixState.self,           PTZNone.self,               PTZCalibrationMatrix.self)
    #PTZState("RWD", PTZCalibrationSaturationState.self,       PTZCalibrationRange.self,   PTZCalibrationSaturation.self)
    #PTZState("RWD", PTZContrastState.self,                    PTZNone.self,               PTZContrast.self)
    #PTZState("RWD", PTZSaturationState.self,                  PTZNone.self,               PTZSaturation.self)
    #PTZState("RWD", PTZSharpnessState.self,                   PTZNone.self,               PTZSharpness.self)
    #PTZState("RWD", PTZWhiteBalanceState.self,                PTZNone.self,               PTZWhiteBalance.self)
    #PTZState( "W" , PTZWhiteBalanceCalibrationAction.self,    PTZNone.self,               PTZNone.self)
    #PTZState("RWD", PTZWhiteBalanceTempState.self,            PTZNone.self,               PTZWhiteBalanceTemp.self)
    #PTZState("RWD", PTZWhiteBalanceTintState.self,            PTZNone.self,               PTZWhiteBalanceTint.self)
    #PTZState("RWD", PTZWhiteLevelState.self,                  PTZNone.self,               PTZWhiteLevel.self)

    // Function
    #PTZState("RWD", PTZClockState.self,                       PTZClock.self,              UInt32.self)
    #PTZState("RWD", PTZDevModeState.self,                     PTZNone.self,               PTZBool.self)
    #PTZState( "W" , PTZDrunkTestAction.self,                  PTZNone.self,               PTZNone.self)
    #PTZState("R"  , PTZDrunkTestPhaseState.self,              PTZNone.self,               PTZDrunkTestPhase.self)
    #PTZState("R"  , PTZHelloState.self,                       PTZNone.self,               PTZHello.self)
    #PTZState("RWD", PTZLedState.self,                         PTZNone.self,               PTZLed.self)
    #PTZState("RWD", PTZLedIntensityState.self,                PTZNone.self,               PTZLedIntensity.self)
    #PTZState("RWD", PTZPowerState.self,                       PTZNone.self,               PTZPower.self)
    #PTZState( "W" , PTZResetAction.self,                      PTZNone.self,               PTZReset.self)
    #PTZState("RWD", PTZSleepTimeoutState.self,                PTZNone.self,               PTZSleepTimeout.self)
    #PTZState("R"  , PTZStatisticsState.self,                  PTZStatisticsGroup.self,    PTZStatisticsValues.self)

    // Image
    #PTZState("RWD", PTZGreyscaleState.self,                   PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZInvertedState.self,                    PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZMireState.self,                        PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZNoiseReductionState.self,              PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZSensorSmoothingState.self,             PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZVideoOutputState.self,                 PTZNone.self,               PTZVideoOutput.self)
    #PTZState("RWD", PTZVignetteCorrectionState.self,          PTZNone.self,               PTZBool.self)
    
    // Light
    #PTZState("RWD", PTZAutoExposureState.self,                PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZBacklightCompensationState.self,       PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZColorGainState.self,                   PTZColorGainChannel.self,   PTZColorGain.self)
    #PTZState("R"  , PTZEffectiveGainState.self,               PTZNone.self,               PTZEffectiveGain.self)
    #PTZState("RWD", PTZGainModeState.self,                    PTZNone.self,               PTZGainMode.self)
    #PTZState("RWD", PTZIrisLevelState.self,                   PTZNone.self,               PTZIrisLevel.self)
    #PTZState("RWD", PTZShutterSpeedState.self,                PTZNone.self,               PTZShutterSpeed.self)
    #PTZState("RWD", PTZWideDynamicRangeState.self,            PTZNone.self,               PTZBool.self)

    // Position
    #PTZState("RWD", PTZAutoFocusState.self,                   PTZNone.self,               PTZBool.self)
    #PTZState("RWD", PTZFocusState.self,                       PTZNone.self,               PTZFocus.self)
    #PTZState( "W" , PTZFocusAction.self,                      PTZNone.self,               PTZNone.self)
    #PTZState( "W" , PTZMoveFocusAction.self,                  PTZFocusDirection.self,     PTZFocusSpeed.self)
    #PTZState( "W" , PTZMovePanAction.self,                    PTZPanDirection.self,       PTZPanSpeed.self)
    #PTZState( "W" , PTZMoveTiltAction.self,                   PTZTiltDirection.self,      PTZTiltSpeed.self)
    #PTZState( "W" , PTZMoveZoomAction.self,                   PTZZoomDirection.self,      PTZZoomSpeed.self)
    #PTZState("RWD", PTZPanState.self,                         PTZNone.self,               PTZPan.self)
    #PTZState("RWD", PTZPositionState.self,                    PTZNone.self,               PTZPosition.self)
    #PTZState("RWD", PTZPresetState.self,                      PTZPreset.self,             PTZPosition.self)
    #PTZState("RWD", PTZTiltState.self,                        PTZNone.self,               PTZTilt.self)
    #PTZState("RWD", PTZZoomState.self,                        PTZNone.self,               PTZZoom.self)
}
