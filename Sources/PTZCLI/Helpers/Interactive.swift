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
}

internal extension Interactive {
    protocol Element: Identifiable {
        var id: String { get }
        var output: String { get }
        var selectable: Bool { get }
        var children: [any Interactive.Element] { get }
        func input(char: WideChar, camera: Camera) -> Bool
    }
    
    protocol RefreshableElement: Element {
        func refresh()
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
    
    class Move<T: PTZWriteable>: Interactive.Element {
        let id = UUID().uuidString
        private let camera: Camera
        private let directions: [Direction: T.Variant]
        private var lastDirectionV: T.Variant
        private var lastDirection: Direction = .stop
        private var lastError: String?
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
        
        private func move(_ direction: Direction) {
            do {
                try camera.set(T(speed, for: directions[direction]!))
                lastDirection = direction
                lastDirectionV = directions[direction]!
            }
            catch {
                lastError = error.localizedDescription
            }
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
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .code(260): // left
                let dir = Direction.allCases.elementBefore(lastDirection, or: Direction.allCases.first!)
                move(dir)
                
            case .code(261): // right
                let dir = Direction.allCases.elementAfter(lastDirection, or: Direction.allCases.last!)
                move(dir)

            case .char(" "): // space
                move(.stop)
                
            default:
                return false
            }
            return true
        }
    }
    
    class State<T: PTZReadable & PTZWriteable>: Interactive.RefreshableElement where T.Value: PTZValue {
        let id = UUID().uuidString
        private let camera: Camera
        private let variant: T.Variant
        private var values: Array<T.Value>
        private let defaultValue: T.Value
        private var currentValue: T.Value
        private var lastError: String?

        convenience init(_ state: T.Type, for camera: Camera, values: any Collection<T.Value>, default: T.Value) where T.Variant == PTZNone {
            self.init(state, for: camera, variant: .init(), values: values, default: `default`)
        }

        convenience init(_ state: T.Type, for camera: Camera, default: T.Value) where T.Variant == PTZNone, T.Value: PTZValue {
            self.init(state, for: camera, variant: .init(), values: T.Value.allCases, default: `default`)
        }

        convenience init(_ state: T.Type, for camera: Camera, default: T.Value) where T.Variant == PTZNone, T.Value: PTZScaledValue {
            var values: [T.Value] = T.Value.allCases
            if values.count > 25 {
                let step = max(1, (T.Value.maxValue - T.Value.minValue) / 25)
                values = stride(from: T.Value.minValue, to: T.Value.maxValue, by: step)
                    .map { T.Value(rawValue: $0) }
                    .uniqueOrdered(by: \.rawValue)
            }
            self.init(state, for: camera, variant: .init(), values: values, default: `default`)
        }

        init(_ state: T.Type, for camera: Camera, variant: T.Variant, values: any Collection<T.Value>, default: T.Value) {
            self.camera = camera
            self.variant = variant
            self.values = Array(values)
            self.currentValue = try! camera.get(T.self , for: variant)
            self.defaultValue = `default`
            
            setCurrentValue(currentValue)
        }
        
        private func setCurrentValue(_ value: T.Value) {
        }

        private func set(to value: T.Value) {
            do {
                try camera.set(T.init(value, for: variant))
                currentValue = values.closest(to: value) ?? value
                lastError = nil
            }
            catch {
                lastError = error.localizedDescription
            }
        }

        // RefreshableElement
        func refresh() {
            do {
                let value = try camera.get(T.self, for: variant)
                currentValue = values.closest(to: value) ?? value
                lastError = nil
            }
            catch {
                lastError = error.localizedDescription
            }
        }

        // InteractiveElement
        var output: String {
            var string = "\(T.name) (\(currentValue))"
            if string.count < 30 {
                string = string.padding(toLength: 30, withPad: " ", startingAt: 0)
            }
            string += " <"
            for v in values {
                string += (currentValue == v) ? "O" : "·"
            }
            string += ">"
            if let lastError {
                string += " \(lastError)"
            }
            return string
        }
        var selectable: Bool { true }
        var children: [any Interactive.Element] { [] }
        func input(char: WideChar, camera: Camera) -> Bool {
            switch (char) {
            case .code(260): // left
                let value = values.elementBefore(currentValue, or: values.first!)
                set(to: value)
                
            case .code(261): // right
                let value = values.elementAfter(currentValue, or: values.last!)
                set(to: value)

            case .char(" "): // space
                set(to: defaultValue)
                
            default:
                return false
            }
            return true
        }
    }
}
