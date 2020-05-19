//
//  BaseViewController.swift
//  Utilities
//
//  Created by Jared Sorge on 3/16/20.
//

import UIKit

open class BaseViewController: UIViewController {
    open override func loadView() {
        view = BaseView(windowCallback: { window in
            self.viewWillMove(to: window)
        })
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }

    // swiftformat:disable:next unusedArguments
    open func viewWillMove(to newWindow: UIWindow?) {}
}

private final class BaseView: UIView {
    private let windowCallback: ((UIWindow?) -> Void)?

    init(frame: CGRect = .zero, windowCallback: @escaping (UIWindow?) -> Void) {
        self.windowCallback = windowCallback
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        windowCallback = nil
        super.init(coder: coder)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        windowCallback?(newWindow)
    }
}
