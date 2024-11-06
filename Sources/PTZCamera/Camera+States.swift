//
//  Camera+States.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import PTZMessaging

extension Camera {
    public static func registerKnownStates() {
        PTZConfig.register(PTZAutoExposureState.self)
        PTZConfig.register(PTZAutoFocusState.self)
        PTZConfig.register(PTZBacklightCompensationState.self)
        PTZConfig.register(PTZBrightnessState.self)
        PTZConfig.register(PTZCalibrationHueState.self)
        PTZConfig.register(PTZCalibrationLuminanceState.self)
        PTZConfig.register(PTZCalibrationSaturationState.self)
        PTZConfig.register(PTZCalibrationMatrixState.self)
        PTZConfig.register(PTZClockState.self)
        PTZConfig.register(PTZGreyscaleState.self)
        PTZConfig.register(PTZContrastState.self)
        PTZConfig.register(PTZDevModeState.self)
        PTZConfig.register(PTZDrunkTestAction.self)
        PTZConfig.register(PTZDrunkTestPhaseState.self)
        PTZConfig.register(PTZFocusState.self)
        PTZConfig.register(PTZFocusAction.self)
        PTZConfig.register(PTZGainModeState.self)
        PTZConfig.register(PTZRedGainState.self)
        PTZConfig.register(PTZBlueGainState.self)
        PTZConfig.register(PTZEffectiveGainState.self)
        PTZConfig.register(PTZHelloState.self)
        PTZConfig.register(PTZInvertedState.self)
        PTZConfig.register(PTZIrisLevelState.self)
        PTZConfig.register(PTZLedState.self)
        PTZConfig.register(PTZLedIntensityState.self)
        PTZConfig.register(PTZMireState.self)
        PTZConfig.register(PTZMovePanAction.self)
        PTZConfig.register(PTZMoveTiltAction.self)
        PTZConfig.register(PTZMoveFocusAction.self)
        PTZConfig.register(PTZMoveZoomAction.self)
        PTZConfig.register(PTZNoiseReductionState.self)
        PTZConfig.register(PTZPanState.self)
        PTZConfig.register(PTZPositionState.self)
        PTZConfig.register(PTZPowerState.self)
        PTZConfig.register(PTZPresetState.self)
        PTZConfig.register(PTZResetAction.self)
        PTZConfig.register(PTZSaturationState.self)
        PTZConfig.register(PTZSensorSmoothingState.self)
        PTZConfig.register(PTZSharpnessState.self)
        PTZConfig.register(PTZShutterSpeedState.self)
        PTZConfig.register(PTZSleepTimeoutState.self)
        PTZConfig.register(PTZStatisticsState.self)
        PTZConfig.register(PTZTiltState.self)
        PTZConfig.register(PTZVideoOutputState.self)
        PTZConfig.register(PTZVignetteCorrectionState.self)
        PTZConfig.register(PTZWhiteBalanceState.self)
        PTZConfig.register(PTZWhiteBalanceCalibrationAction.self)
        PTZConfig.register(PTZWhiteBalanceTempState.self)
        PTZConfig.register(PTZWhiteBalanceTintState.self)
        PTZConfig.register(PTZWhiteLevelState.self)
        PTZConfig.register(PTZWideDynamicRangeState.self)
        PTZConfig.register(PTZZoomState.self)
    }
}
