//
//  InteractiveCommand.swift
//  PTZ
//
//  Created by syan on 22/10/2024.
//

import Foundation
import ArgumentParser
import PTZCamera
import SwiftCurses
import ncurses
import PTZMessaging

struct InteractiveCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "interactive")
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?

    private static var lastError: String?
    
    mutating func run() throws(CameraError) {
        Camera.registerKnownStates()

        let camera = try Camera(serial: .givenOrFirst(serial), logLevel: .error)
        try camera.powerOn()
        
        let content: [any Interactive.Element] = [
            Interactive.Line("Let's have some fun!"),
            Interactive.DynamicLine({ Self.lastError ?? "" }, .error),
            Interactive.Line(""),
            Interactive.Group("--- Testing ---", collapsibleSpacing: true, [
                Interactive.State(PTZDevModeState.self, for: camera, default: .on),
            ]),
            Interactive.Group("--- Position ---", collapsibleSpacing: true, [
                Interactive.State(PTZPanState.self, for: camera, default: .default),
                Interactive.State(PTZTiltState.self, for: camera, default: .default),
                Interactive.State(PTZZoomState.self, for: camera, default: .default),
                Interactive.Group("Focus", collapsibleSpacing: false, [
                    Interactive.State(PTZAutoFocusState.self, for: camera, default: .on),
                    Interactive.State(PTZFocusState.self, for: camera, default: .mid),
                ]),
                Interactive.Group("Move", collapsibleSpacing: false, [
                    Interactive.Move(PTZMovePanAction.self, camera: camera, oneWay: .left, otherWay: .right, stop: .stop, speed: .mid),
                    Interactive.Move(PTZMoveTiltAction.self, camera: camera, oneWay: .down, otherWay: .up, stop: .stop, speed: .mid),
                    Interactive.Move(PTZMoveZoomAction.self, camera: camera, oneWay: .out, otherWay: .in, stop: .stop, speed: .mid),
                    Interactive.Move(PTZMoveFocusAction.self, camera: camera, oneWay: .far, otherWay: .near, stop: .stop, speed: .mid),
                ])
            ]),
            Interactive.Group("--- Exposure ---", collapsibleSpacing: true, [
                Interactive.State(PTZShutterSpeedState.self, for: camera, default: .default),
                Interactive.State(PTZAutoExposureState.self, for: camera, default: .on),
                Interactive.State(PTZGainModeState.self, for: camera, default: .default),
                Interactive.State(PTZBacklightCompensationState.self, for: camera, default: .off),
                Interactive.State(PTZWideDynamicRangeState.self, for: camera, default: .off),
                Interactive.State(PTZIrisLevelState.self, for: camera, default: .mid),
                Interactive.State(PTZVignetteCorrectionState.self, for: camera, default: .on),
                Interactive.State(PTZNoiseReductionState.self, for: camera, default: .on),
            ]),
            Interactive.Group("--- Colors ---", collapsibleSpacing: true, [
                Interactive.State(PTZBrightnessState.self, for: camera, default: .default),
                Interactive.State(PTZContrastState.self, for: camera, default: .default),
                Interactive.State(PTZSaturationState.self, for: camera, default: .default),
                Interactive.Group("WhiteBalance", collapsibleSpacing: false, [
                    Interactive.State(PTZWhiteBalanceState.self, for: camera, default: .default),
                    Interactive.State(PTZWhiteBalanceTempState.self, for: camera, default: .default),
                    Interactive.State(PTZWhiteBalanceTintState.self, for: camera, default: .default),
                ]),
                Interactive.State(PTZGainRedState.self, for: camera, default: .default),
                Interactive.State(PTZGainBlueState.self, for: camera, default: .default),
            ]),
        ]

        Interactive.traverse(content) { (element, _, _) in
            if let state = element as? any Interactive.RefreshableElement {
                state.refresh()
            }
        }
        
        do {
            try initScreen(settings: [.noEcho, .cbreak, .colors], windowSettings: [.keypad(true), .timeout(1000)]) { scr in
                if SwiftCurses.Color.hasColors {
                    ncurses.use_default_colors()
                    Interactive.Color.register()
                }
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
                if SwiftCurses.Color.hasColors {
                    try scr.withAttrs(.colorPair(element.outputColor.rawValue)) {
                        try scr.addStr(String(repeating: " ", count: 2 * (path.count - 1)) + element.output)
                    }
                }
                else {
                    try scr.addStr(String(repeating: " ", count: 2 * (path.count - 1)) + element.output)
                }
                
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

            let selectedElementResult = Result(catching: { try selectedElement?.1.input(char: char, camera: camera) ?? false })
            switch selectedElementResult {
            case .success(true): continue
            case .success(false): break
            case .failure(let error):
                if let e = error as? any RecoverableError, !e.recoveryOptions.isEmpty {
                    Self.lastError = error.localizedDescription + " - " + e.recoveryOptions.joined(separator: ", ")
                }
                else {
                    Self.lastError = error.localizedDescription
                }
                continue
            }

            switch (char) {
            case .code(259): // up
                selectedElementID = selectableElements.map(\.1.id).elementBefore(selectedElementID, or: selectableElements.first?.1.id ?? "")
            case .code(258): // down
                selectedElementID = selectableElements.map(\.1.id).elementAfter(selectedElementID, or: selectableElements.last?.1.id ?? "")
            case .char("r"):
                Interactive.traverse(content) { (element, _, _) in
                    if let state = element as? any Interactive.RefreshableElement {
                        state.refresh()
                    }
                }

            default:
                continue
            }
            Self.lastError = nil
        }
    }
}
