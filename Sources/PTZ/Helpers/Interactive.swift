//
//  Interactive.swift
//  PTZ
//
//  Created by syan on 25/10/2024.
//

import Foundation
import SwiftCurses
import PTZCamera
import PTZMessaging

internal struct Interactive {
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
    
    enum Color: Int32 {
        case regular = 1
        case error = 2
        
        static func register() {
            try? ColorPair.define(1, fg: -1, bg: -1)
            try? ColorPair.define(2, fg: SwiftCurses.Color.red, bg: -1)
        }
    }
}

internal extension Interactive {
    protocol Element: Identifiable {
        var id: String { get }
        var output: String { get }
        var outputColor: Interactive.Color { get }
        var selectable: Bool { get }
        var children: [any Interactive.Element] { get }
        func input(char: WideChar, camera: Camera) throws -> Bool
    }
    
    protocol RefreshableElement: Element {
        func refresh()
    }
    
    struct Line: Interactive.Element {
        let id = UUID().uuidString
        let output: String
        let outputColor: Interactive.Color
        init(_ output: String, _ color: Interactive.Color = .regular) {
            self.outputColor = color
            self.output = output
        }
        
        // InteractiveElement
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    struct DynamicLine: Interactive.Element {
        let id = UUID().uuidString
        let outputClosure: () -> String
        let outputColor: Interactive.Color
        init(_ output: @escaping () -> String, _ color: Interactive.Color = .regular) {
            self.outputColor = color
            self.outputClosure = output
        }

        // InteractiveElement
        var output: String { outputClosure() }
        var selectable: Bool { false }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool { false }
    }
    
    class Group: Interactive.Element {
        let id = UUID().uuidString
        let name: String
        let collapsibleSpacing: Bool
        let items: [any Interactive.Element]
        
        init(_ name: String, collapsibleSpacing: Bool, defaultOpened: Bool, _ items: [any Interactive.Element]) {
            self.opened = defaultOpened
            self.name = name
            self.collapsibleSpacing = collapsibleSpacing
            self.items = items
        }

        // InteractiveElement
        var output: String { name + (opened ? "" : " (+)") }
        var outputColor: Interactive.Color { .regular }
        var selectable: Bool { true }
        private var opened: Bool
        var children: [any Interactive.Element] {
            let separator = collapsibleSpacing ? [Line("")] : []
            return opened ? (items + separator) : []
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
        var outputColor: Interactive.Color { .regular }
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
    
    class Move<T: PTZWritable>: Interactive.Element {
        let id = UUID().uuidString
        private let camera: Camera
        private let directions: [Direction: T.Variant]
        private var lastDirectionV: T.Variant
        private var lastDirection: Direction = .stop
        private let speed: T.Value
        private enum Direction: CaseIterable {
            case oneWay, stop, otherWay
        }
        
        init(_ type: T.Type, camera: Camera, oneWay: T.Variant, otherWay: T.Variant, stop: T.Variant, speed: T.Value) {
            self.camera = camera
            self.directions = [.oneWay: oneWay, .otherWay: otherWay, .stop: stop]
            self.lastDirectionV = stop
            self.speed = speed
        }
        
        private func move(_ direction: Direction) throws {
            try camera.set(T(speed, for: directions[direction]!))
            lastDirection = direction
            lastDirectionV = directions[direction]!
        }

        // InteractiveElement
        var output: String {
            var string = "\(T.name) (\(lastDirectionV.description))"
            if string.count < 30 {
                string = string.padding(toLength: 30, withPad: " ", startingAt: 0)
            }
            
            let symbolOneWay   = lastDirection == .oneWay   ? "O" : "·"
            let symbolStop     = lastDirection == .stop     ? "O" : "·"
            let symbolOtherWay = lastDirection == .otherWay ? "O" : "·"
            
            string += " <\(symbolOneWay)·\(symbolStop)·\(symbolOtherWay)>"
            return string
        }
        var outputColor: Interactive.Color { .regular }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) throws -> Bool {
            switch (char) {
            case .code(260): // left
                let dir = Direction.allCases.elementBefore(lastDirection, or: Direction.allCases.first!)
                try move(dir)
                
            case .code(261): // right
                let dir = Direction.allCases.elementAfter(lastDirection, or: Direction.allCases.last!)
                try move(dir)

            case .char(" "): // space
                try move(.stop)
                
            default:
                return false
            }
            return true
        }
    }
    
    class State<T: PTZReadable & PTZWritable>: Interactive.RefreshableElement where T.Value: PTZValue {
        let id = UUID().uuidString
        private let camera: Camera
        private let variant: T.Variant
        private var values: Array<T.Value>
        private let defaultValue: T.Value
        private var currentValue: T.Value

        convenience init(_ state: T.Type, on camera: Camera, default: T.Value) where T.Value: PTZScaledValue, T.Variant == PTZNone {
            self.init(state, for: .init(), on: camera, default: `default`)
        }

        convenience init(_ state: T.Type, on camera: Camera, default: T.Value) where T.Value: PTZValue, T.Variant == PTZNone {
            self.init(state, for: .init(), on: camera, values: T.Value.allCases, default: `default`)
        }

        convenience init(_ state: T.Type, for variant: T.Variant, on camera: Camera, default: T.Value) where T.Value: PTZScaledValue {
            var values: [T.Value] = T.Value.allCases

            if values.count > 25 {
                let step = max(1, (T.Value.maxValue - T.Value.minValue) / 25)
                values = stride(from: T.Value.minValue, to: T.Value.maxValue, by: step)
                    .map { T.Value(rawValue: $0) }
                    .uniqueOrdered(by: \.rawValue)
            }

            self.init(state, for: variant, on: camera, values: values, default: `default`)
        }

        init(_ state: T.Type, for variant: T.Variant, on camera: Camera, values: any Collection<T.Value>, default: T.Value) {
            self.camera = camera
            self.variant = variant
            self.values = Array(values)
            self.currentValue = values.first!
            self.defaultValue = `default`

            refresh()
        }
        
        private func set(to value: T.Value) throws {
            try camera.set(T.init(value, for: variant))
            currentValue = values.closest(to: value) ?? value
        }

        // RefreshableElement
        func refresh() {
            let value = try! camera.get(T.self, for: variant)
            currentValue = values.closest(to: value) ?? value
        }

        // InteractiveElement
        var output: String {
            var string = ""
            string += T.name
            if !(variant is PTZNone) {
                string += "(\(variant))"
            }
            string += " (\(currentValue))"
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
        var outputColor: Interactive.Color { .regular }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) throws -> Bool {
            switch (char) {
            case .code(260): // left
                let value = values.elementBefore(currentValue, or: values.first!)
                try set(to: value)
                
            case .code(261): // right
                let value = values.elementAfter(currentValue, or: values.last!)
                try set(to: value)

            case .char(" "): // space
                try set(to: defaultValue)
                
            default:
                return false
            }
            return true
        }
    }
}
