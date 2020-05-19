//
//  UIAlertController+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 4/28/20.
//

import UIKit

extension UIAlertAction {
    /// Adds an action to the controller in a style that's more inline with Combine (allowing creation of actions
    /// to be chained with adding to the alert controller)
    /// - Parameter alertController: The controller to add the action to
    public func addingTo(_ alertController: UIAlertController) {
        alertController.addAction(self)
    }

    /// A cancel action
    public static var cancel: UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
    }
}
