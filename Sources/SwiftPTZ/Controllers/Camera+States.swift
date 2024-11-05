//
//  Camera+States.swift
//  SwiftPTZ
//
//  Created by syan on 30/10/2024.
//

import Foundation

// MARK: Actions
extension Camera {
    func powerOn() {
        let sequence: [any PTZReadable & PTZWriteable] = [
            PTZDevModeState(.on),
            PTZMireState(.off),
            PTZColorsState(.on),
            PTZLedState(.init(color: .default, mode: .default)),
            PTZLedIntensityState(.init(r: .default, g: .default, b: .default)),
            PTZVideoOutputState(.default),
            PTZShutterSpeedState(.default),
            // PTZRequestSetPosition(pan: .default, tilt: .default, zoom: .default),
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
        send(PTZPowerState(.on).set())
        send(PTZHelloState.get(), retries: [.untilAck])

        for state in sequence {
            try! set(state, debounce: true)
        }
        log(.info, "Finished boot sequence")
    }
    
    func powerOff() {
        send(PTZLedState(.init(color: .off, mode: .off)).set())
        send(PTZPowerState(.standby).set())

        /*
        while serial.readAllBytes() != [0x00] {
            Thread.sleep(forTimeInterval: 0.1)
        }
         */
    }
}
