//
//  FlowController.swift
//  Utilities
//
//  Created by Jared Sorge on 2/17/20.
//

import UIKit

/// This class is intened to be subclassed. It provides functionality found at the root of a module to handle basic
/// navigation whether it is pushed on to a navigation stack or presented modally. It's main goal is to answer the
/// question of how to push a new, self-contained workflow on to the navigation stack.
open class FlowController: BaseViewController {
    private enum NavigationState {
        case injected(UINavigationController)
        case selfMade(UINavigationController)

        var navigationController: UINavigationController {
            switch self {
            case .injected(let nav):
                return nav
            case .selfMade(let nav):
                return nav
            }
        }
    }

    private let rootViewController: UIViewController
    private let navState: NavigationState

    public override var navigationController: UINavigationController? {
        return navState.navigationController
    }

    /// Creates an instance. If there is a navigation controller passed in, then the assumption is made that this class
    /// is being presented modally with the passed root view controller being the root of a new navigation controller.
    /// If there is a navigation controller injected, then the root view controller passed in will be embedded inside
    /// this class and this class can be pushed on to a navigation stack.
    ///
    /// - Parameters:
    ///   - rootViewController: The view controller at the root of the flow
    ///   - navigation: The navigation controller this instance will be pushed on to, if there is one.
    public init(rootViewController: UIViewController, navigation: UINavigationController?) {
        self.rootViewController = rootViewController

        if let navigation = navigation {
            navState = .injected(navigation)
        } else {
            navState = .selfMade(UINavigationController(rootViewController: UIViewController()))
        }

        super.init(nibName: nil, bundle: nil)

        navigationItem.backBarButtonItem = .emptyBackButton
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        switch navState {
        case .injected:
            title = rootViewController.title
            addChild(rootViewController, containerView: view)

        case .selfMade(let nav):
            nav.setViewControllers([rootViewController], animated: false)
            addChild(nav, containerView: view)
        }
    }

    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navState.navigationController.pushViewController(viewController, animated: animated)
    }

    public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        navState.navigationController.setViewControllers(viewControllers, animated: animated)
    }

    public func popToRoot(animated: Bool) {
        switch navState {
        case .injected(let navigation):
            navigation.popToViewController(self, animated: animated)
        case .selfMade(let navigation):
            navigation.popToRootViewController(animated: animated)
        }
    }
}
