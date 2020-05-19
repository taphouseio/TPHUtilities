//
//  ActivityHUD.swift
//  Marco
//
//  Created by Jared Sorge on 4/12/20.
//

import UIKit

public final class ActivityHUD: UIView {
    public init() {
        super.init(frame: .zero)

        backgroundColor = .secondarySystemBackground

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tintColor = .label
        activityIndicator.startAnimating()
        activityIndicator.style = .large
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            activityIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
        ])

        layer.cornerRadius = 5.0

        constrainToSquare(sideSize: 90.0)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showInView(_ view: UIView) {
        view.addSubview(self)

        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    public func hide() {
        removeFromSuperview()
    }
}
