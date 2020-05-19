//
//  ResponderBox.swift
//  Utilities
//
//  Created by Jared Sorge on 5/11/20.
//

import Foundation

/// This class can wrap up a type that is not friendly to the Objective-C responder chain.
public final class ResponderBox: NSObject {
    @nonobjc
    private let value: Any

    @nonobjc
    public init<T>(_ value: T) {
        self.value = value
        super.init()
    }

    @nonobjc
    public func value<T>(_: T.Type = T.self) -> T {
        guard let value = value as? T else {
            fatalError("Invalid value: expected \(T.self), found \(type(of: self.value))")
        }

        return value
    }
}
