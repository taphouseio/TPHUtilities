//
//  UserDefaultsWrapper.swift
//  Utilities
//
//  Created by Jared Sorge on 4/16/20.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    public init(_ key: String, defaultValue: T, defaults: UserDefaults = .standard) {
        _key = key
        _defaultValue = defaultValue
        _defaults = defaults
    }

    public var wrappedValue: T {
        get {
            return _defaults.object(forKey: _key) as? T ?? _defaultValue
        }
        set {
            _defaults.set(newValue, forKey: _key)
        }
    }

    private let _key: String
    private let _defaultValue: T
    private let _defaults: UserDefaults
}
