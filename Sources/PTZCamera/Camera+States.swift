//
//  Camera+States.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import PTZMessaging
import PTZCameraMacros

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
        PTZConfig.register(PTZGainModeState.self)
        PTZConfig.register(PTZGainRedState.self)
        PTZConfig.register(PTZGainBlueState.self)
        PTZConfig.register(PTZGainEffectiveState.self)
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
    #PTZState("RW", PTZBrightnessState.self,                  PTZNone.self,               PTZBrightness.self)
    #PTZState("RW", PTZCalibrationHueState.self,              PTZCalibrationRange.self,   PTZCalibrationHue.self)
    #PTZState("RW", PTZCalibrationLuminanceState.self,        PTZCalibrationRange.self,   PTZCalibrationLuminance.self)
    #PTZState("RW", PTZCalibrationMatrixState.self,           PTZNone.self,               PTZCalibrationMatrix.self)
    #PTZState("RW", PTZCalibrationSaturationState.self,       PTZCalibrationRange.self,   PTZCalibrationSaturation.self)
    #PTZState("RW", PTZContrastState.self,                    PTZNone.self,               PTZContrast.self)
    #PTZState("RW", PTZSaturationState.self,                  PTZNone.self,               PTZSaturation.self)
    #PTZState("RW", PTZSharpnessState.self,                   PTZNone.self,               PTZSharpness.self)
    #PTZState("RW", PTZWhiteBalanceState.self,                PTZNone.self,               PTZWhiteBalance.self)
    #PTZState( "W", PTZWhiteBalanceCalibrationAction.self,    PTZNone.self,               PTZNone.self)
    #PTZState("RW", PTZWhiteBalanceTempState.self,            PTZNone.self,               PTZWhiteBalanceTemp.self)
    #PTZState("RW", PTZWhiteBalanceTintState.self,            PTZNone.self,               PTZWhiteBalanceTint.self)
    #PTZState("RW", PTZWhiteLevelState.self,                  PTZNone.self,               PTZWhiteLevel.self)

    // Function
    #PTZState("RW", PTZClockState.self,                       PTZClock.self,              UInt32.self)
    #PTZState("RW", PTZDevModeState.self,                     PTZNone.self,               PTZBool.self)
    #PTZState( "W", PTZDrunkTestAction.self,                  PTZNone.self,               PTZNone.self)
    #PTZState("R" , PTZDrunkTestPhaseState.self,              PTZNone.self,               PTZDrunkTestPhase.self)
    #PTZState("R" , PTZHelloState.self,                       PTZNone.self,               PTZHello.self)
    #PTZState("RW", PTZLedState.self,                         PTZNone.self,               PTZLed.self)
    #PTZState("RW", PTZLedIntensityState.self,                PTZNone.self,               PTZLedIntensity.self)
    #PTZState("RW", PTZPowerState.self,                       PTZNone.self,               PTZPower.self)
    #PTZState( "W", PTZResetAction.self,                      PTZNone.self,               PTZReset.self)
    #PTZState("RW", PTZSleepTimeoutState.self,                PTZNone.self,               PTZSleepTimeout.self)
    #PTZState("R" , PTZStatisticsState.self,                  PTZStatisticsGroup.self,    PTZStatisticsValues.self)

    // Image
    #PTZState("RW", PTZGreyscaleState.self,                   PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZInvertedState.self,                    PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZMireState.self,                        PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZNoiseReductionState.self,              PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZSensorSmoothingState.self,             PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZVideoOutputState.self,                 PTZNone.self,               PTZVideoOutput.self)
    #PTZState("RW", PTZVignetteCorrectionState.self,          PTZNone.self,               PTZBool.self)
    
    // Light
    #PTZState("RW", PTZAutoExposureState.self,                PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZBacklightCompensationState.self,       PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZGainModeState.self,                    PTZNone.self,               PTZGainMode.self)
    #PTZState("RW", PTZGainRedState.self,                     PTZNone.self,               PTZColorGain.self)
    #PTZState("RW", PTZGainBlueState.self,                    PTZNone.self,               PTZColorGain.self)
    #PTZState("R" , PTZGainEffectiveState.self,               PTZNone.self,               PTZGainEffective.self)
    #PTZState("RW", PTZIrisLevelState.self,                   PTZNone.self,               PTZIrisLevel.self)
    #PTZState("RW", PTZShutterSpeedState.self,                PTZNone.self,               PTZShutterSpeed.self)
    #PTZState("RW", PTZWideDynamicRangeState.self,            PTZNone.self,               PTZBool.self)

    // Position
    #PTZState("RW", PTZAutoFocusState.self,                   PTZNone.self,               PTZBool.self)
    #PTZState("RW", PTZFocusState.self,                       PTZNone.self,               PTZFocus.self)
    #PTZState( "W", PTZFocusAction.self,                      PTZNone.self,               PTZNone.self)
    #PTZState( "W", PTZMoveFocusAction.self,                  PTZFocusDirection.self,     PTZFocusSpeed.self)
    #PTZState( "W", PTZMovePanAction.self,                    PTZPanDirection.self,       PTZPanSpeed.self)
    #PTZState( "W", PTZMoveTiltAction.self,                   PTZTiltDirection.self,      PTZTiltSpeed.self)
    #PTZState( "W", PTZMoveZoomAction.self,                   PTZZoomDirection.self,      PTZZoomSpeed.self)
    #PTZState("RW", PTZPanState.self,                         PTZNone.self,               PTZPan.self)
    #PTZState("RW", PTZPositionState.self,                    PTZNone.self,               PTZPosition.self)
    #PTZState("RW", PTZPresetState.self,                      PTZPreset.self,             PTZPosition.self)
    #PTZState("RW", PTZTiltState.self,                        PTZNone.self,               PTZTilt.self)
    #PTZState("RW", PTZZoomState.self,                        PTZNone.self,               PTZZoom.self)
}
