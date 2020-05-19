//
//  PlaceholderTextView.swift
//  Utilities
//
//  Created by Jared Sorge on 1/31/20.
//

import Combine
import UIKit

public final class PlaceholderTextView: UIView {
    private var cancellables = [AnyCancellable]()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.font = self.font
        label.textColor = .lightGray
        label.contentMode = .topLeft
        return label
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        return textView
    }()

    public var font: UIFont = UIFont.preferredFont(forTextStyle: .body) {
        didSet {
            placeholderLabel.font = font
            textView.font = font
        }
    }

    public var placeholderTextColor: UIColor = UIColor.placeholderText {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }

    public var typingTextColor: UIColor = UIColor.label {
        didSet {
            var newAttributes = textView.typingAttributes
            newAttributes[.foregroundColor] = typingTextColor
            textView.typingAttributes = newAttributes
        }
    }

    @Published
    public var placeholderText = ""

    @Published
    public var text = "" {
        didSet {
            self.textView.text = self.text
            self.placeholderLabel.isHidden = self.text.hasCharacters
        }
    }

    convenience init() {
        self.init(frame: .zero)

        addSubview(placeholderLabel)
        addSubview(textView)

        let placeholderTop = placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 13.0)
        NSLayoutConstraint.activate([
            placeholderTop,
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            textView.topAnchor.constraint(equalTo: placeholderLabel.topAnchor),
            textView.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -placeholderTop.constant),
        ])

        let placeholderSub = $placeholderText.sink(receiveValue: { text in
            self.placeholderLabel.text = text
        })
        cancellables.append(placeholderSub)

        bringSubviewToFront(placeholderLabel)

        placeholderLabel.textColor = placeholderTextColor
        textView.typingAttributes = [
            .foregroundColor: typingTextColor,
            .font: font,
        ]
    }

    public override var canBecomeFirstResponder: Bool {
        return textView.canBecomeFirstResponder
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    public override var canResignFirstResponder: Bool {
        return textView.canResignFirstResponder
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    public override var inputView: UIView? {
        get { return textView.inputView }
        set { textView.inputView = newValue }
    }

    public override func endEditing(_ force: Bool) -> Bool {
        return textView.endEditing(force)
    }

    public var accessoryView: UIView? {
        get { return nil }
        set { textView.inputAccessoryView = newValue }
    }
}

extension PlaceholderTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        guard textView.text.last != "\n" else {
            _ = resignFirstResponder()
            textView.text = textView.text.trimmingCharacters(in: .newlines)
            return
        }

        let text = textView.text ?? ""
        placeholderLabel.isHidden = text.hasCharacters
        self.text = text
    }
}

private extension String {
    var hasCharacters: Bool {
        return isEmpty == false
    }
}
