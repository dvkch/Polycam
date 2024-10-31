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
        #warning("define proper states to avoid setting to a value that is already used")
        let sequence: [any PTZRequest] = [
            PTZRequestSetPowerMode(mode: .on),
            PTZRequestHelloMPTZ11(),
            PTZRequestSetDevMode(enabled: .on),
            PTZRequestSetMireMode(enabled: .off),
            PTZRequestSetColors(enabled: .on),
            PTZRequestSetLedMode(color: .default, mode: .default),
            PTZRequestSetLedIntensity(red: .default, green: .default, blue: .default),
            PTZRequestSetVideoOutputMode(mode: .default),
            PTZRequestSetShutterSpeed(speed: .default),
            // PTZRequestSetPosition(pan: .default, tilt: .default, zoom: .default),
            PTZRequestSetInvertedMode(enabled: .off),
            PTZRequestSetAutoFocus(enabled: .on),
            PTZRequestSetWhiteBalance(mode: .default),
            PTZRequestSetGainMode(gain: .default),
            PTZRequestSetRedGain(gain: .default),
            PTZRequestSetBlueGain(gain: .default),
            PTZRequestSetBrightness(brightness: .default),
            PTZRequestSetSaturation(saturation: .default),
            PTZRequestSetBacklightCompensation(enabled: .off)
        ]

        log(.info, "Starting boot sequence...")
        for request in sequence {
            var retries: [Camera.RetryConditions] = [.onError(.modeCondition)]
            if !(request is PTZRequestSetPowerMode) {
                retries.append(.untilAck)
            }
            send(request, retries: [.onError(.modeCondition)])
        }
        log(.info, "Finished boot sequence")
    }
    
    func powerOff() {
        send(PTZRequestSetLedMode(color: .off, mode: .off))
        send(PTZRequestSetPowerMode(mode: .standby))

        /*
        while serial.readAllBytes() != [0x00] {
            Thread.sleep(forTimeInterval: 0.1)
        }
         */
    }
}

#warning("complete")
extension Camera {
    var pan: PTZPan {
        get { return try! get(PTZRequestGetPan()).pan }
        set { send(PTZRequestSetPan(pan: newValue)) }
    }
    var tilt: PTZTilt {
        get { return try! get(PTZRequestGetTilt()).tilt }
        set { send(PTZRequestSetTilt(tilt: newValue)) }
    }
    var zoom: PTZZoom {
        get { return try! get(PTZRequestGetZoom()).zoom }
        set { send(PTZRequestSetZoom(zoom: newValue)) }
    }
    var focus: (PTZBool, PTZFocus) {
        get { return (try! get(PTZRequestGetAutoFocus()).enabled, try! get(PTZRequestGetFocus()).focus) }
        set { send(PTZRequestSetAutoFocus(enabled: newValue.0)); send(PTZRequestSetFocus(focus: newValue.1)) }
    }
}
