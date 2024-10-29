//
//  InteractiveCommand.swift
//  SwiftPTZ
//
//  Created by syan on 22/10/2024.
//

import Foundation
import ArgumentParser
import AppKit
import SwiftCurses

struct InteractiveCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "interactive")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error
        try camera.sendRequest(PTZRequestSetDevMode(enabled: .on))
        
        #warning("find a way to use properly defined states instead")
        let content: [any Interactive.Element] = [
            Interactive.Line("Let's have some fun!"),
            Interactive.Line(""),
            Interactive.Group("--- Testing ---", [
                Interactive.State("Dev mode", cat: 0x01, r: 0x0B, values: 0...1, default: 0),
            ]),
            Interactive.Group("--- Position ---", [
                Interactive.State("Pan",   cat: 0x03, r: 0x04, value: PTZPan.self),
                Interactive.State("Tilt",  cat: 0x03, r: 0x05, value: PTZTilt.self),
                Interactive.State("Zoom",  cat: 0x03, r: 0x02, value: PTZZoom.self),
                Interactive.Group("Focus", [
                    Interactive.State("Auto", cat: 0x02, r: 0x09, values: [0, 1], default: 1),
                    Interactive.State("Manual", cat: 0x03, r: 0x03, value: PTZFocus.self),
                ]),
                Interactive.Group("Move", PTZDirection.allCases.map { dir in
                    Interactive.Action(name: dir.description, state: "") { _ in
                        try! camera.sendRequest(PTZRequestSetMove(direction: dir, panTiltSpeed: .speed3, zoomSpeed: .speed2, focusSpeed: .speed3))
                        return ""
                    }
                })
            ]),
            Interactive.Group("--- Exposure ---", [
                Interactive.State("Shutter speed", cat: 0x02, r: 0x14, value: PTZShutterSpeed.self),
                Interactive.State("Auto exposure", cat: 0x02, r: 0x11, values: [0, 1], default: 1),
                Interactive.State("Gain",  cat: 0x01, r: 0x31, value: PTZGainMode.self),
                Interactive.State("Backlight compensation", cat: 0x02, r: 0x15, values: [0, 1], default: 1),
                Interactive.State("Iris level", cat: 0x03, r: 0x00, value: PTZIrisLevel.self),
                Interactive.State("Vignette correction", cat: 0x01, r: 0x3D, values: [0, 1], default: 1),
                Interactive.State("Noise reduction", cat: 0x01, r: 0x3C, values: [0, 1], default: 1),
            ]),
            Interactive.Group("--- Colors ---", [
                Interactive.State("Brightness", cat: 0x01, r: 0x33, value: PTZBrightness.self),
                Interactive.State("Contrast",   cat: 0x01, r: 0x32, value: PTZContrast.self),
                Interactive.State("Saturation", cat: 0x03, r: 0x3e, value: PTZSaturation.self),
                Interactive.Group("WhiteBalance", [
                    Interactive.State("Mode", cat: 0x02, r: 0x12, value: PTZWhiteBalance.self),
                    Interactive.State("Temp", cat: 0x03, r: 0x41, value: PTZWhiteBalanceTemp.self),
                    Interactive.State("Tint", cat: 0x03, r: 0x40, value: PTZWhiteBalanceTint.self),
                ]),
                Interactive.State("GainR", cat: 0x03, r: 0x42, value: PTZColorGain.self),
                Interactive.State("GainB", cat: 0x03, r: 0x43, value: PTZColorGain.self),
            ]),
        ]

        Interactive.traverse(content) { (element, _, _) in
            if let state = element as? Interactive.State {
                state.refresh(for: camera)
            }
        }
        
        do {
            try initScreen(settings: [.noEcho, .cbreak], windowSettings: [.keypad(true), .timeout(1000)]) { scr in
                try tui(scr: scr, content: content, camera: camera)
            }
        }
        catch {
            print("/!\\", error)
        }
    }
    
    private func tui(scr: Window, content: [any Interactive.Element], camera: Camera) throws {
        var selectedElementID: String?

        while true {
            var selectableElements: [(Int, any Interactive.Element)] = []

            scr.clear()
            try scr.move(row: 0, col: 0)
            try Interactive.traverse(content) { (element, idx, path) in
                try scr.move(row: Int32(idx), col: 0)
                try scr.addStr(String(repeating: " ", count: 2 * (path.count - 1)) + element.output)
                
                if element.selectable {
                    selectableElements.append((idx, element))
                }
            }
            
            let selectedElement = selectableElements.first(where: { $0.1.id == selectedElementID }) ?? selectableElements.first
            selectedElementID = selectedElement?.1.id

            if let selectedElement {
                try scr.move(row: Int32(selectedElement.0), col: 0)
            }

            let charOrError = Result(catching: { try scr.getChar() })
            guard case let .success(char) = charOrError else { continue }

            if let selectedElement, selectedElement.1.input(char: char, camera: camera) {
                continue
            }

            switch (char) {
            case .code(259): // up
                selectedElementID = selectableElements.map(\.1.id).elementBefore(selectedElementID, or: selectableElements.first?.1.id ?? "")
            case .code(258): // down
                selectedElementID = selectableElements.map(\.1.id).elementAfter(selectedElementID, or: selectableElements.last?.1.id ?? "")
            case .char("r"):
                Interactive.traverse(content) { (element, _, _) in
                    if let state = element as? Interactive.State {
                        state.refresh(for: camera)
                    }
                }

            default:
                continue
            }
        }
    }
}
