import UIKit

/// Convenience Layout Guide for moving constraints in relation to the keyboard.
///
/// To use, create an instance of `KeyboardLayoutGuide` and add it to your main view, then attach the
/// bottom anchor of the view you want to the keyboard layout guide's top anchor. You should also update the
/// constraint when the view's layout changes.
///
/// Your view should have backup constraints for when the keyboard is off screen that can break when the
/// keyboard is shown.
///
/// Sample code:
/// ```
/// private let keyboardLayoutGuide = KeyboardLayoutGuide()
///
/// override func viewDidLoad() {
///     super.viewDidLoad()
///     self.view.addLayoutGuide(self.keyboardLayoutGuide)
///
///     let keyboardConstraint = self.circularButton.bottomAnchor.constraint(
///         lessThanOrEqualTo: self.keyboardLayoutGuide.topAnchor)
///     keyboardConstraint.isActive = true
/// }
/// ```
public final class KeyboardLayoutGuide: UILayoutGuide {
    /// Singleton class used to maintain an up to date keyboard frame. This is necesary so that views can have
    /// updated keyboard size as soon as they appear.
    private final class KeyboardListener {
        /// The current frame of the keyboard in screen coordinates
        var currentFrame = CGRect.zero

        /// Set containing all the keyboard layout guides to update when the keyboard frame changes
        var layoutGuides = Set<KeyboardLayoutGuide>()

        init() {
            NotificationCenter.default.addObserver(
                self, selector: #selector(keyboardFrameChanged(notification:)),
                name: UIResponder.keyboardWillChangeFrameNotification, object: nil
            )
        }

        @objc
        private func keyboardFrameChanged(notification: NSNotification) {
            guard let info = notification.userInfo else {
                preconditionFailure("KeyboardLayoutGuide: No notification info for keyboard")
            }

            guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                preconditionFailure("KeyboardLayoutGuide: No end keyboard size")
            }

            currentFrame = keyboardFrame

            for layoutGuide in layoutGuides {
                layoutGuide.updateConstraintsAnimated(info: info)
            }
        }
    }

    private static let listener = KeyboardListener()

    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    private var allConstraints: [NSLayoutConstraint] {
        return [
            leadingConstraint, trailingConstraint, heightConstraint, bottomConstraint,
        ].compactMap { $0 }
    }

    public override var owningView: UIView? {
        didSet { updateForOwningView() }
    }

    /// The current frame of the keyboard in screen coordinates
    public var currentScreenFrame: CGRect {
        return KeyboardLayoutGuide.listener.currentFrame
    }

    /// The current frame of the keyboard in it's owning view's coordinates
    public var currentFrame: CGRect? {
        let keyboardFrame = currentScreenFrame
        guard let owningView = self.owningView, keyboardFrame != .zero else {
            // Layout guide is not attatched to a view
            return nil
        }

        // Convert the keyboard frame from screen coordinates to its owning view's coordinates
        return owningView.convert(keyboardFrame, from: nil)
    }

    public override init() {
        super.init()
        identifier = "KeyboardLayoutGuide"
        KeyboardLayoutGuide.listener.layoutGuides.insert(self)
    }

    deinit {
        self.stopObservingFrameChanges()
        KeyboardLayoutGuide.listener.layoutGuides.remove(self)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Create or replace the keyboard layout constraint
    private func updateForOwningView() {
        stopObservingFrameChanges()

        // Remove all previous owner's constraints
        NSLayoutConstraint.deactivate(allConstraints)

        guard let owningView = self.owningView else {
            leadingConstraint = nil
            trailingConstraint = nil
            heightConstraint = nil
            bottomConstraint = nil
            return
        }

        // Create new constraints
        leadingConstraint = leadingAnchor.constraint(equalTo: owningView.leadingAnchor)
        trailingConstraint = trailingAnchor.constraint(equalTo: owningView.trailingAnchor)
        bottomConstraint = bottomAnchor.constraint(equalTo: owningView.bottomAnchor)
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)

        // Adjust keyboard frame and update constant
        updateConstraints()

        // Remove all new constraints
        NSLayoutConstraint.activate(allConstraints)

        beginObservingFrameChanges()
    }

    /// Update the layout guide constraints
    ///
    /// You should call this in your view controller's `viewDidLayoutSubviews()` method
    public func update() {
        updateConstraints()
    }

    /// Update the constraints of the layout guide based on the keybaord frame
    private func updateConstraints() {
        guard let owningView = self.owningView, let keyboardFrame = currentFrame,
            keyboardFrame != .zero else {
            return
        }

        bottomConstraint?.constant = keyboardFrame.maxY - owningView.frame.height
        heightConstraint?.constant = keyboardFrame.height

        owningView.setNeedsUpdateConstraints()
    }

    /// Update the constraints of the layout guide based on the keybaord frame with an animation
    ///
    /// - parameter info: Additional info for the animation
    private func updateConstraintsAnimated(info: [AnyHashable: Any]) {
        let startKeyboardFrame = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
        let animationDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let animationCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 7

        // Skip keyboard change if size is the same
        guard startKeyboardFrame != currentFrame else {
            return
        }

        // Adjust keyboard frame and update constant
        updateConstraints()

        // Animate the change
        UIView.animate(
            withDuration: animationDuration, delay: 0,
            options: [
                .init(rawValue: animationCurve), .allowUserInteraction, .beginFromCurrentState,
            ],
            animations: { [weak self] in
                self?.owningView?.layoutIfNeeded()
            }
        )
    }

    // MARK: - Key value observing

    /// Owner view's frame change observation
    private var ownerViewObservation: NSKeyValueObservation?

    /// Begin observing owner view's frame
    private func beginObservingFrameChanges() {
        ownerViewObservation = owningView?.observe(\.frame, changeHandler: { [weak self] _, _ in
            // Update needs to be called in the next run loop to ensure view layout has finsihed
            DispatchQueue.main.async {
                self?.update()
            }
        })
    }

    /// Stop observing owner view's frame
    private func stopObservingFrameChanges() {
        ownerViewObservation?.invalidate()
        ownerViewObservation = nil
    }
}
