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
