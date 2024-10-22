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
        try camera.sendRequest(PTZRequestSetNoiseReduction(enabled: .on))
        try camera.sendRequest(PTZRequestSetContrast(contrast: .default))
        try camera.sendRequest(PTZRequestSetVignetteCorrection(enabled: .on))
        try camera.sendRequest(PTZRequestSetGainMode(gain: .auto))
        try camera.sendRequest(PTZRequestSetWhiteBalance(mode: .auto))
        try camera.sendRequest(PTZRequestSetAutoFocus(enabled: .off))

        let r1: [UInt16] = Array(0x7B...0x85) // + Array(0x7B...0x85).reversed()
        let r2: [UInt16] = Array(0x76...0x8A) // + Array(0x76...0x8A).reversed()

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
                ])
            ]),
            Interactive.Group("--- Colors ---", [
                Interactive.State("Brightness", cat: 0x01, r: 0x33, value: PTZBrightness.self),
                Interactive.State("Contrast", cat: 0x01, r: 0x32, value: PTZContrast.self),
                Interactive.State("Saturation", cat: 0x03, r: 0x3e, value: PTZSaturation.self),
                Interactive.Group("WhiteBalance", [
                    Interactive.State("Mode", cat: 0x02, r: 0x12, value: PTZWhiteBalance.self),
                    Interactive.State("Temp", cat: 0x03, r: 0x41, value: PTZWhiteBalanceTemp.self),
                    Interactive.State("Tint", cat: 0x03, r: 0x40, value: PTZWhiteBalanceTint.self),
                ]),
                Interactive.State("GainR", cat: 0x03, r: 0x42, value: PTZColorGain.self),
                Interactive.State("GainB", cat: 0x03, r: 0x43, value: PTZColorGain.self),
            ]),
            /*
            Interactive.Group("--- Group 0 ---", [
                Interactive.State("50", cat: 0x03, r: 0x50, values: r1, default: 128), // amount of red, 7B to 01 05
                Interactive.State("51", cat: 0x03, r: 0x51, values: r1, default: 128), // same, veeeeeery small increments
                Interactive.State("52", cat: 0x03, r: 0x52, values: r1, default: 128), // r
                Interactive.State("53", cat: 0x03, r: 0x53, values: r1, default: 128), // r
                Interactive.State("54", cat: 0x03, r: 0x54, values: r1, default: 128), // lum bleu
                Interactive.State("55", cat: 0x03, r: 0x55, values: r1, default: 128), // r
                Interactive.Line(""),
                Interactive.State("56", cat: 0x03, r: 0x56, values: r2, default: 128), // amount of red (smaller increments)
                Interactive.State("57", cat: 0x03, r: 0x57, values: r2, default: 128), // amount of green, smaller increments), joue sur la luminosité un peu, ou balance des couleurs mais plus globale à l'image
                Interactive.State("58", cat: 0x03, r: 0x58, values: r2, default: 128), // rien
                Interactive.State("59", cat: 0x03, r: 0x59, values: r2, default: 128), // highlights de blancs +/-
                Interactive.State("5A", cat: 0x03, r: 0x5A, values: r2, default: 128), // à quel point la feuille de papier est bleue
                Interactive.State("5B", cat: 0x03, r: 0x5B, values: r2, default: 128), // r
                Interactive.Line(""),
                Interactive.State("5C", cat: 0x03, r: 0x5C, values: r2, default: 128), // saturation/ présence de rouge (skin tone changé mais pas coussin vert)
                Interactive.State("5D", cat: 0x03, r: 0x5D, values: r2, default: 128), // amount of yellow? jaune change, mais pas vert, ni autre ?
                Interactive.State("5E", cat: 0x03, r: 0x5E, values: r2, default: 128), //
                Interactive.State("5F", cat: 0x03, r: 0x5F, values: r2, default: 128), // quantité de bleu dans les highlights (coin de fenetre qui se bleute)
                Interactive.State("60", cat: 0x03, r: 0x60, values: r2, default: 128), // feuille de appier se bleute à nouveau
                Interactive.State("61", cat: 0x03, r: 0x61, values: r2, default: 128), //
            ]),
            */
            Interactive.Group("--- Group 0 ---", [
                Interactive.State("50", cat: 0x03, r: 0x50, values: r1, default: 128), // amount of red, 7B to 01 05
                Interactive.State("56", cat: 0x03, r: 0x56, values: r2, default: 128), // amount of red (smaller increments)
                Interactive.State("5C", cat: 0x03, r: 0x5C, values: r2, default: 128), // saturation/ présence de rouge (skin tone changé mais pas coussin vert)
            ]),
            Interactive.Group("--- Group 1 ---", [
                Interactive.State("51", cat: 0x03, r: 0x51, values: r1, default: 128), // same, veeeeeery small increments
                Interactive.State("57", cat: 0x03, r: 0x57, values: r2, default: 128), // amount of green, smaller increments), joue sur la luminosité un peu, ou balance des couleurs mais plus globale à l'image
                Interactive.State("5D", cat: 0x03, r: 0x5D, values: r2, default: 128), // amount of yellow? jaune change, mais pas vert, ni autre ?
            ]),
            Interactive.Group("--- Group 3 ---", [
                Interactive.State("53", cat: 0x03, r: 0x53, values: r1, default: 128), // r
                Interactive.State("59", cat: 0x03, r: 0x59, values: r2, default: 128), // highlights de blancs +/-
                Interactive.State("5F", cat: 0x03, r: 0x5F, values: r2, default: 128), // quantité de bleu dans les highlights (coin de fenetre qui se bleute)
            ]),
            Interactive.Group("--- Group 4 ---", [
                Interactive.State("54", cat: 0x03, r: 0x54, values: r1, default: 128), // lum bleu
                Interactive.State("5A", cat: 0x03, r: 0x5A, values: r2, default: 128), // à quel point la feuille de papier est bleue
                Interactive.State("60", cat: 0x03, r: 0x60, values: r2, default: 128), // feuille de appier se bleute à nouveau
            ]),
            Interactive.Group("--- Group 2 ---", [
                Interactive.State("52", cat: 0x03, r: 0x52, values: r1, default: 128), // r
                Interactive.State("58", cat: 0x03, r: 0x58, values: r2, default: 128), // rien
                Interactive.State("5E", cat: 0x03, r: 0x5E, values: r2, default: 128), //
            ]),
            Interactive.Group("--- Group 5 ---", [
                Interactive.State("55", cat: 0x03, r: 0x55, values: r1, default: 128), // r
                Interactive.State("5B", cat: 0x03, r: 0x5B, values: r2, default: 128), // r
                Interactive.State("61", cat: 0x03, r: 0x61, values: r2, default: 128), //
            ]),
        ]

        Interactive.traverse(content) { (element, _, _) in
            if let state = element as? Interactive.State {
                state.refresh(for: camera)
            }
        }
        
        do {
            try initScreen(settings: [.noEcho, .cbreak], windowSettings: [.keypad(true)]) { scr in
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

            let char = try scr.getChar()
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
    
    class State: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let category: UInt8
        let register: UInt8
        private(set) var values: Array<UInt16>
        let `default`: UInt16
        private var currentValue: UInt16 = 0

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
            try! camera.sendRequest(req)
            currentValue = values.closest(to: value) ?? value
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
