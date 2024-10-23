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
            Interactive.DynamicLine { try! camera.get(PTZRequestGetPosition()).description },
            Interactive.Line(""),
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

fileprivate struct Interactive {
    static func traverse(_ elements: [any Interactive.Element], closure: (any Element, Int, IndexPath) throws -> ()) rethrows {
        try traverse(elements, indexOffset: 0, parentPath: IndexPath(), closure: closure)
    }
    
    private static func traverse(_ elements: [any Element], indexOffset: Int, parentPath: IndexPath, closure: (any Element, Int, IndexPath) throws -> ()) rethrows {
        var compoundIndex = indexOffset
        for (i, el) in elements.enumerated() {
            try closure(el, compoundIndex, parentPath.appending(i))
            compoundIndex += 1

            try traverse(el.children, indexOffset: compoundIndex, parentPath: parentPath.appending(i)) {
                compoundIndex += 1
                try closure($0, $1, $2)
            }
        }
    }
    
    protocol Element: Identifiable {
        var id: String { get }
        var output: String { get }
        var selectable: Bool { get }
        var children: [any Interactive.Element] { get }
        func input(char: WideChar, camera: Camera) -> Bool
    }
    
    struct Line: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        init(_ name: String) {
            self.name = name
        }
        
        // InteractiveElement
        var output: String { name }
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    struct DynamicLine: Interactive.Element {
        let id = UUID().uuidString
        let name: () -> String
        
        // InteractiveElement
        var output: String { name() }
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    class Group: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let items: [any Interactive.Element]
        
        init(_ name: String, _ items: [any Interactive.Element]) {
            self.name = name
            self.items = items
        }

        // InteractiveElement
        var output: String { name + (opened ? "" : " (+)") }
        var selectable: Bool { true }
        private var opened = true
        var children: [any Interactive.Element] {
            opened ? items + [Interactive.Line("")] : []
        }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .char(" "): // space
                opened.toggle()
                
            default:
                return false
            }
            return true
        }
    }
    
    class Action<T: CustomStringConvertible>: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        var state: T
        let action: (T) -> T
        
        init(name: String, state: T, action: @escaping (T) -> T) {
            self.name = name
            self.state = state
            self.action = action
        }
        
        // InteractiveElement
        var output: String { "\(name) (\(state))" }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .char(" "): // space
                state = action(state)
            default:
                return false
            }
            return true
        }
    }
    
    class State: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let category: UInt8
        let register: UInt8
        private(set) var values: Array<UInt16>
        let `default`: UInt16
        private var currentValue: UInt16 = 0
        private var setError: String? = nil

        convenience init<T: PTZScaledValue>(_ name: String, cat category: UInt8, r register: UInt8, value: T.Type) {
            self.init(name, cat: category, r: register, values: T.min.ptzValue...T.max.ptzValue, default: T.default.ptzValue)
        }

        convenience init<T: PTZValue & CaseIterable>(_ name: String, cat category: UInt8, r register: UInt8, value: T.Type) {
            self.init(name, cat: category, r: register, values: T.allCases.map(\.ptzValue), default: T.default.ptzValue)
        }

        init(_ name: String, cat category: UInt8, r register: UInt8, values: any Collection<UInt16>, default: UInt16) {
            self.name = name
            self.category = category
            self.register = register
            self.values = values.map { $0 }
            self.default = `default`
            
            if values.count > 30 {
                self.values = stride(from: 0, to: self.values.count - 1, by: max(1, self.values.count / 30)).map { self.values[$0] }
            }
        }
        
        func refresh(for camera: Camera) {
            let (bytes, _) = try! camera.sendRequest2(PTZUnknownRequest(commandBytes: [category, register], arg: nil))
            let value = PTZMessage.messages(from: bytes).last!.parseArgument(type: PTZUInt.self, position: .single).ptzValue
            currentValue = values.closest(to: value) ?? value
        }
        
        func set(for camera: Camera, to value: UInt16) {
            let req = PTZUnknownRequest(commandBytes: [category + 0x40, register], arg: value)
            let reply = try! camera.sendRequest(req)
            currentValue = values.closest(to: value) ?? value
            setError = (reply is PTZReplyExecuted) ? nil : "\(req.bytes.stringRepresentation) => \(reply.description)"
        }
        
        // InteractiveElement
        var output: String {
            var string = "\(name) (\(currentValue))"
            if string.count < 30 {
                string = string.padding(toLength: 30, withPad: " ", startingAt: 0)
            }
            string += " <"
            for v in values {
                string += (currentValue == v) ? "O" : "·"
            }
            string += ">"
            if let setError {
                string += " \(setError)"
            }
            return string
        }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .code(260): // left
                let value = values.elementBefore(currentValue, or: values.first!)
                set(for: camera, to: value)
                
            case .code(261): // right
                let value = values.elementAfter(currentValue, or: values.last!)
                set(for: camera, to: value)

            case .char(" "): // space
                set(for: camera, to: `default`)
                
            default:
                return false
            }
            return true
        }
    }
}
