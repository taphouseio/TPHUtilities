//
//  LogoutNotification.swift
//  Utilities
//
//  Created by Jared Sorge on 3/8/20.
//

import Foundation

public struct UserDidLogout: NotificationDescriptor {
    public typealias Payload = Void

    public static var noteName = Notification.Name("UserDidLogoutNotification")
}
