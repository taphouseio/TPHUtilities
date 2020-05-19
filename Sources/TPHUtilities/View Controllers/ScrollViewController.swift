//
//  ScrollViewController.swift
//  Utilities
//
//  Created by Jared Sorge on 1/13/20.
//

import UIKit

/// A closure that takes in 3 X axis layout constraints and can produce an array of constraints. The 3
/// arguments will always be a leading, trailing, and center constraint in that order.
public typealias HorizontalConstraintBuilder = (NSLayoutXAxisAnchor, NSLayoutXAxisAnchor, NSLayoutXAxisAnchor)
    -> [NSLayoutConstraint]

/// A view controller who's main view embeds a scroll view, which is pinned to the safe area on all sides.
open class ScrollViewController: BaseViewController {
    private let insets: UIEdgeInsets
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.backgroundColor = .systemBackground
        return view
    }()

    public init(insets: UIEdgeInsets) {
        self.insets = insets

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        let scrollViewConstraints = scrollView.pinEdgesToContainer(safeArea: [.top, .bottom])

        scrollView.addSubview(contentView)
        contentView.pinEdgesToContainer()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        let layoutGuide = KeyboardLayoutGuide()
        view.addLayoutGuide(layoutGuide)
        scrollView.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        scrollViewConstraints?.bottom.priority = .defaultLow
    }

    @available(*, unavailable, message: "Use `init()` instead")
    public override init(nibName _: String?, bundle _: Bundle?) {
        fatalError("Use `init()` instead")
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.sendSubviewToBack(scrollView)

        addBottomConstraintIfNeeded()
    }

    open override func viewWillMove(to _: UIWindow?) {
        addBottomConstraintIfNeeded()
    }

    open override func viewDidLayoutSubviews() {
        let bottomInset: CGFloat
        if let insettingView = fetchViewToInsetBy() {
            bottomInset = view.frame.height - insettingView.frame.origin.y
        } else {
            bottomInset = 40.0
        }

        scrollView.contentInset = UIEdgeInsets(top: 20.0, left: 0, bottom: bottomInset, right: 0)
    }

    /// Called to get the view at the bottom of the scroll view (assuming that there is a vertical stack
    /// of views in the scroll view). This must be overridden by a subclass.
    open func fetchBottomViewInScrollView() -> UIView? {
        let bottomView = contentView.subviews
            .sorted(by: { $0.frame.origin.y > $1.frame.origin.y })
            .first
        return bottomView
    }

    /// Called to retrieve the view by which to inset the scroll view at the bottom of the screen. Useful
    /// in the case where a button floats over the top of the scrollable content, and the content needs
    /// to scroll in order to not be obstructed.
    open func fetchViewToInsetBy() -> UIView? {
        return nil
    }

    /// Adds a given view to the scroll view, positioned to pin along the edges of the scroll view.
    /// - Parameters:
    ///   - view: The view being added to the scroll view
    ///   - aboveView: The view above the view being added. If nil then it's assumed this view goes at the top
    ///                of the scroll view.
    ///   - spacingAbove: The amount of spacing to put between the top of the new view and the view above (if there is one)
    public func addToScrollView(_ view: UIView, comingAfter aboveView: UIView?, spacingAbove: CGFloat = 44.0) {
        var comingAfterConfig: (UIView, CGFloat)?
        if let aboveView = aboveView {
            comingAfterConfig = (aboveView, spacingAbove)
        }

        addToScrollView(
            view, comingAfter: comingAfterConfig,
            horizontalConstraintBuilder: { leading, trailing, _ in
                return [
                    view.leadingAnchor.constraint(equalTo: leading, constant: self.insets.left),
                    view.trailingAnchor.constraint(equalTo: trailing, constant: -self.insets.right),
                ]
            }
        )
    }

    /// Adds a given view to the scroll view with the ability to customize relative position. Callers will
    /// have to horizontally align the new view manually as part of the constraint builder closure.
    /// - Parameters:
    ///   - view: The view being added to the scroll view
    ///   - comingAfter: If this view is coming after a view already in the scroll view, then this will define which
    ///    view and how much spacing to provide between the bottom of the above view and the top of the new view. If
    ///    this is nil, then the new view will be placed at the top of the scroll view.
    ///   - horizontalConstraintBuilder: A closure that allows the opportunity to build the horizontal constraints for
    ///   the new view. The constraints passed in are for the leading and trailing closures of the enclosing view, as
    ///   well as the center X of the enclosing view.
    public func addToScrollView(_ view: UIView, comingAfter: (aboveView: UIView, spacing: CGFloat)?,
                                horizontalConstraintBuilder: HorizontalConstraintBuilder) {
        contentView.addSubview(view)

        let topConstraint: NSLayoutConstraint
        if let (aboveView, spacing) = comingAfter {
            topConstraint = view.topAnchor.constraint(equalTo: aboveView.bottomAnchor, constant: spacing)
        } else {
            topConstraint = view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top)
        }

        var constraintsToAdd = [topConstraint]
        let horizontals = horizontalConstraintBuilder(contentView.leadingAnchor,
                                                      contentView.trailingAnchor,
                                                      contentView.centerXAnchor)
        constraintsToAdd.append(contentsOf: horizontals)

        NSLayoutConstraint.activate(constraintsToAdd)
    }

    private func addBottomConstraintIfNeeded() {
        func hasAddedBottomViewConstraint() -> Bool {
            guard let bottomView = fetchBottomViewInScrollView() else {
                return false
            }

            let constraint = bottomView.constraints
                .first(where: {
                    ($0.firstItem as? NSLayoutYAxisAnchor) == bottomView.bottomAnchor ||
                        ($0.firstItem as? NSLayoutYAxisAnchor) == bottomView.bottomAnchor
                })

            return constraint != nil
        }

        view.layoutIfNeeded()

        guard hasAddedBottomViewConstraint() == false else { return }

        fetchBottomViewInScrollView()?.bottomAnchor
            .constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom).isActive = true
    }
}
