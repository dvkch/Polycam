//
//  States.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import PTZMessaging

extension Camera {
    public static func configureKnownStates() {
        PTZMessaging.knownReadableStates = [
            PTZAutoExposureState.self,
            PTZAutoFocusState.self,
            PTZBacklightCompensationState.self,
            PTZBrightnessState.self,
            PTZCalibrationHueState.self, PTZCalibrationLuminanceState.self, PTZCalibrationSaturationState.self,
            PTZClockState.self,
            PTZColorsState.self,
            PTZContrastState.self,
            PTZDevModeState.self,
            PTZDrunkTestPhaseState.self,
            PTZFocusState.self,
            PTZGainModeState.self, PTZEffectiveGainState.self, PTZRedGainState.self, PTZBlueGainState.self,
            PTZHelloState.self,
            PTZInvertedState.self,
            PTZIrisLevelState.self,
            PTZLedIntensityState.self,
            PTZLedState.self,
            PTZMireState.self,
            PTZMotorStatsState.self,
            PTZNoiseReductionState.self,
            PTZPanState.self,
            PTZPositionState.self,
            PTZPowerState.self,
            PTZPresetState.self,
            PTZSaturationState.self,
            PTZSensorSmoothingState.self,
            PTZSharpnessState.self,
            PTZShutterSpeedState.self,
            PTZSleepTimeoutState.self,
            PTZTiltState.self,
            PTZVideoOutputState.self,
            PTZVignetteCorrectionState.self,
            PTZWhiteBalanceState.self,
            PTZWhiteBalanceTempState.self,
            PTZWhiteBalanceTintState.self,
            PTZWhiteLevelState.self,
            PTZWideDynamicRangeState.self,
            PTZZoomState.self,
        ]
    }
}
