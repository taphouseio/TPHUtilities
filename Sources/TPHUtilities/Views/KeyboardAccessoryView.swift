//
//  KeyboardAccessoryView.swift
//  Utilities
//
//  Created by Jared Sorge on 12/23/19.
//

import UIKit

public final class KeyboardButton {
    public enum Appearance {
        case text(String)
        case icon(UIImage?)
    }

    let appearance: Appearance
    let action: CodeBlock
    var barButton: UIBarButtonItem?

    public class func doneButton(action: @escaping CodeBlock) -> KeyboardButton {
        return self.init(appearance: .text("Done"), action: action)
    }

    public init(appearance: Appearance, action: @escaping CodeBlock) {
        self.appearance = appearance
        self.action = action
    }

    /// Creates a bar button item from the keyboard button instance. The resulting bar button item is
    /// associated with this instance as the `barButton` property.
    /// - Parameters:
    ///   - target: The target of the button press
    ///   - action: The action of the button press
    func asBarButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        let button: UIBarButtonItem

        switch appearance {
        case .text(let text):
            button = UIBarButtonItem(title: text, style: .plain, target: target, action: action)
        case .icon(let image):
            button = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        }
        button.tintColor = UIColor.label

        barButton = button
        return button
    }
}

/// A UIToolbar subclass that adds a toolbar to a keyboard. Can support a left button, centered title,
///  and right button.
public final class KeyboardAccessoryView: UIToolbar {
    private let leftButtons: [KeyboardButton]
    private let rightButton: KeyboardButton?
    private let centerLabel = UILabel(frame: .zero)

    public var centerText: String? {
        didSet {
            centerLabel.text = centerText
        }
    }

    public override var intrinsicContentSize: CGSize {
        let supersize = super.intrinsicContentSize
        return CGSize(width: supersize.width, height: 44.0)
    }

    public init(
        frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 33.0),
        leftButtons: [KeyboardButton]?, rightButton: KeyboardButton?, title: String?
    )
    {
        self.leftButtons = leftButtons ?? []
        self.rightButton = rightButton
        super.init(frame: frame)

        var leftItems = [UIBarButtonItem]()
        var middleItem: UIBarButtonItem?
        var rightItem: UIBarButtonItem?

        if let leftButtons = leftButtons {
            leftItems = leftButtons.map { $0.asBarButton(target: self,
                                                         action: #selector(self.aLeftButtonTapped(_:))) }
        }

        centerLabel.text = title ?? ""
        centerLabel.sizeToFit()
        middleItem = UIBarButtonItem(customView: centerLabel)
        middleItem?.tintColor = .black

        if let rightButton = rightButton {
            rightItem = rightButton.asBarButton(target: self, action: #selector(rightButtonTapped))
        }

        let spacerButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var toolbarItems = [leftItems].flatMap { $0 }
        let otherItems = [spacerButton, middleItem, spacerButton, rightItem].compactMap { $0 }
        toolbarItems.append(contentsOf: otherItems)
        setItems(toolbarItems, animated: false)

        backgroundColor = .white
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func rightButtonTapped() {
        rightButton?.action()
    }

    @objc
    private func aLeftButtonTapped(_ item: UIBarButtonItem) {
        let button = leftButtons.first(where: { $0.barButton == item })
        button?.action()
    }
}
