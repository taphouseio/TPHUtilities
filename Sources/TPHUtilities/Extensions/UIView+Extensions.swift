//
//  UIView+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 1/7/20.
//

import UIKit

extension UIView {
    public struct SafeArea: RawRepresentable, OptionSet {
        public typealias RawValue = Int
        public var rawValue: RawValue

        public init(rawValue: Self.RawValue) {
            self.rawValue = rawValue
        }

        public static var top = SafeArea(rawValue: 1 << 0)
        public static var bottom = SafeArea(rawValue: 1 << 1)
        public static var left = SafeArea(rawValue: 1 << 2)
        public static var right = SafeArea(rawValue: 1 << 3)
    }

    /// Iterates over the view's subviews and returns the first responder if it is in the view's hierarchy.
    public func findViewThatIsFirstResponder() -> UIView? {
        guard isFirstResponder == false else {
            return self
        }

        for subview in subviews {
            let firstResponder = subview.findViewThatIsFirstResponder()
            if firstResponder != nil {
                return firstResponder
            }
        }

        return nil
    }

    /// Constrains the view's size to be a square
    /// - Parameter sideSize: The size for the sides of the square
    public func constrainToSquare(sideSize: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: sideSize),
            heightAnchor.constraint(equalToConstant: sideSize),
        ])
    }

    /// Pins a view's edges to the view's supervieww
    @discardableResult
    public func pinEdgesToContainer(safeArea: SafeArea = [], insets: UIEdgeInsets = .zero)
        -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, leading: NSLayoutConstraint,
        trailing: NSLayoutConstraint)?
    {
        guard let superview = self.superview else {
            return nil
        }

        var superLeading = superview.leadingAnchor
        var superTrailing = superview.trailingAnchor
        var superTop = superview.topAnchor
        var superBottom = superview.bottomAnchor

        if safeArea.contains(.left) {
            superLeading = superview.safeAreaLayoutGuide.leadingAnchor
        }
        if safeArea.contains(.right) {
            superTrailing = superview.safeAreaLayoutGuide.trailingAnchor
        }
        if safeArea.contains(.top) {
            superTop = superview.safeAreaLayoutGuide.topAnchor
        }
        if safeArea.contains(.bottom) {
            superBottom = superview.safeAreaLayoutGuide.bottomAnchor
        }

        let leading = leadingAnchor.constraint(equalTo: superLeading, constant: insets.left)
        let trailing = trailingAnchor.constraint(equalTo: superTrailing, constant: -insets.right)
        let top = topAnchor.constraint(equalTo: superTop, constant: insets.top)
        let bottom = bottomAnchor.constraint(equalTo: superBottom, constant: -insets.bottom)

        let constraints = [leading, trailing, top, bottom]
        NSLayoutConstraint.activate(constraints)

        return (top, bottom, leading, trailing)
    }

    /// Pins a view's edges to the layout guide
    @discardableResult
    public func pinEdgesToLayoutGuide(layoutGuide: UILayoutGuide)
        -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, leading: NSLayoutConstraint,
            trailing: NSLayoutConstraint)?
    {
        let leading = leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor)
        let trailing = trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        let top = topAnchor.constraint(equalTo: layoutGuide.topAnchor)
        let bottom = bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)

        let constraints = [leading, trailing, top, bottom]
        NSLayoutConstraint.activate(constraints)

        return (top, bottom, leading, trailing)
    }

    /// Pins a view's center X and Y anchors to its superview's center X and Y
    public func pinCenterToContainerCenter() {
        guard let superview = self.superview else {
            return
        }

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        ])
    }
}
