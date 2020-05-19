//
//  KeyboardNotifications.swift
//  Utilities
//
//  Created by Jared Sorge on 12/25/19.
//

import UIKit

public struct KeyboardNotificationPayload {
    public let animationCurve: UIView.AnimationCurve
    public let duration: TimeInterval
    public let keyboardIsLocal: Bool
    public let frameBegin: CGRect
    public let frameEnd: CGRect
}

public struct KeyboardWillShowNotification: NotificationDescriptor {
    public static let noteName = UIWindow.keyboardWillShowNotification

    public typealias Payload = KeyboardNotificationPayload

    public static func decode(_ note: Notification) -> KeyboardWillShowNotification.Payload {
        let userInfo = note.userInfo ?? [:]
        return parseInfoDictionaryIntoPayload(userInfo)
    }
}

public struct KeyboardWillHideNotification: NotificationDescriptor {
    public static let noteName = UIWindow.keyboardWillHideNotification

    public typealias Payload = KeyboardNotificationPayload

    public static func decode(_ note: Notification) -> KeyboardWillHideNotification.Payload {
        let userInfo = note.userInfo ?? [:]
        return parseInfoDictionaryIntoPayload(userInfo)
    }
}

public struct KeyboardWillChangeFrameNotification: NotificationDescriptor {
    public static let noteName = UIWindow.keyboardWillChangeFrameNotification

    public typealias Payload = KeyboardNotificationPayload

    public static func decode(_ note: Notification) -> KeyboardWillChangeFrameNotification.Payload {
        let userInfo = note.userInfo ?? [:]
        return parseInfoDictionaryIntoPayload(userInfo)
    }
}

private func parseInfoDictionaryIntoPayload(_ dict: [AnyHashable: Any]) -> KeyboardNotificationPayload {
    let curve = dict[UIView.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve ?? .easeInOut
    let duration = (dict[UIView.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 2.0
    let isLocal = (dict[UIView.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue ?? false
    let frameBegin = (dict[UIView.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    let frameEnd = (dict[UIView.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

    return KeyboardNotificationPayload(animationCurve: curve, duration: duration, keyboardIsLocal: isLocal,
                                       frameBegin: frameBegin, frameEnd: frameEnd)
}
