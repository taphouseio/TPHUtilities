//
//  NSNotification+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 12/25/19.
//

import Foundation

/// Lets us define types that can have type-safe notification payloads
public protocol NotificationDescriptor {
    associatedtype Payload
    static var noteName: Notification.Name { get }
    static func encode(payload: Payload) -> Notification
    static func decode(_ note: Notification) -> Payload
}

extension NotificationDescriptor {
    static var _modelKey: String {
        return "ModelKey"
    }

    public static func encode(payload: Payload) -> Notification {
        let info = [_modelKey: payload]
        let note = Notification(name: noteName, object: nil, userInfo: info)
        return note
    }

    public static func decode(_ note: Notification) -> Payload {
        let model = note.userInfo![_modelKey] as! Payload
        return model
    }
}

/// These are vended when adding a NotificationDescriptor observer for a Notification. Hold on to the
/// resulting token for the lifetime of the observation. When the token deallocates the observation
/// is removed.
public final class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter

    public init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    deinit {
        center.removeObserver(token)
    }
}

extension NotificationToken {
    /// Convenience to store a token in a collection without having to cast it to a variable and store the variable.
    /// - Parameter collection: The collection to put the token in
    public func store(in collection: inout [NotificationToken]) {
        collection.append(self)
    }
}

extension NotificationCenter {
    public func addObserver<A: NotificationDescriptor>(
        descriptor: A.Type,
        queue: OperationQueue? = nil,
        using block: @escaping (A.Payload) -> Void
    ) -> NotificationToken {
        let token = addObserver(forName: descriptor.noteName, object: nil, queue: queue, using: { note in
            block(descriptor.decode(note))
        })
        return NotificationToken(token: token, center: self)
    }
}
