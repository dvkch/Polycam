//
//  Camera+Sequences.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

public extension Camera {
    func powerOnIfNeeded() throws(CameraError) {
        guard try power() == .on else { return }
        try powerOnIfNeeded()
    }

    func powerOn() throws(CameraError) {
        log(.info, "Starting boot sequence...")

        try setPower(.on)
        while (try? hello()) == nil {
            Thread.sleep(forTimeInterval: 0.05)
        }
        try setDevMode(.on)
        try setMire(.on)
        try setGreyscale(.off)
        try setLed(.init(color: .default, mode: .default))
        try setLedIntensity(.init(r: .default, g: .default, b: .default))
        try setVideoOutput(.default)
        try setShutterSpeed(.default)
        try setInverted(.off)
        try setAutoFocus(.on)
        try setWhiteBalance(.default)
        try setGainMode(.default)
        try setGainRed(.default)
        try setGainBlue(.default)
        try setBrightness(.default)
        try setSaturation(.default)
        try setBacklightCompensation(.off)

        log(.info, "Finished boot sequence")
    }
        
    func powerOff() {
        log(.info, "Starting power off sequence...")

        try? set(PTZLedState(.init(color: .off, mode: .off)))
        send(PTZPowerState(.standby).set(), retries: [.untilZeros])

        log(.info, "Finished power off sequence...")
    }
}
