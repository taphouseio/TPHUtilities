//
//  DividerView.swift
//  Utilities
//
//  Created by Jared Sorge on 3/8/20.
//

import UIKit

public final class DividerView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .label
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 1.0).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DividerView {
    public static func addTo(view: UIView) {
        let divider = DividerView(frame: .zero)

        if let stack = view as? UIStackView {
            stack.addArrangedSubview(divider)
            divider.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        } else {
            view.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
    }
}
