//
//  UIViewController+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 11/19/19.
//

import UIKit

extension UIViewController {
    /// Adds the view controller as a child to the parent view controller, and pins its view to the container's edges.
    /// - Parameters:
    ///   - viewController: The view controller to add
    ///   - containerView: The container view to add the view controller's view to
    ///   - layoutGuide: The layout guide to align the child's view to, if that kind of alignment is desired
    ///   - insets: An amount to inset the child by, if desired
    public func addChild(_ viewController: UIViewController, containerView: UIView, layoutGuide: UILayoutGuide? = nil,
                         insets: UIEdgeInsets = .zero) {
        addChild(viewController)

        containerView.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        let leading = layoutGuide?.leadingAnchor ?? containerView.leadingAnchor
        let trailing = layoutGuide?.trailingAnchor ?? containerView.trailingAnchor
        let top = layoutGuide?.topAnchor ?? containerView.topAnchor
        let bottom = layoutGuide?.bottomAnchor ?? containerView.bottomAnchor

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: leading, constant: insets.left),
            viewController.view.trailingAnchor.constraint(equalTo: trailing, constant: -insets.right),
            viewController.view.topAnchor.constraint(equalTo: top, constant: insets.top),
            viewController.view.bottomAnchor.constraint(equalTo: bottom, constant: -insets.bottom),
        ])
    }

    /// Removes the receiver from its parent view controller, and removes the view from its former view
    /// heirarchy
    public func completelyRemoveFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    /// Adds a close button in the upper right corner of the view controller. Default implementation of that button
    /// is to dismiss itself, but that can be overridden with the target/action injected.
    /// - Parameters:
    ///   - target: The target of the button
    ///   - action: The action performed on the button's tap
    public func addCloseButton(target: Any? = self, action: Selector = #selector(closeButtonTapped)) {
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: target,
                                                  action: action)
    }

    /// Closes the current view controller with animation via `dismiss`. This is here primarily to be called via
    /// selector, whereas `dismiss(animated:,completion:)` cannot.
    @objc
    public func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    /// Presents an alert controller with an OK button and the localized text of the given error.
    /// - Parameter error: The error to present.
    public func presentError(_ error: Error, additionalActions actions: [UIAlertAction] = []) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(ok)

        actions.forEach({ $0.addingTo(alertVC) })

        present(alertVC, animated: true, completion: nil)
    }
}
