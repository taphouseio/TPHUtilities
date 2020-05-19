//
//  UIBarButtonItem.swift
//  Utilities
//
//  Created by Jared Sorge on 1/7/20.
//

import UIKit

extension UIBarButtonItem {
    public static var emptyBackButton: UIBarButtonItem {
        let button = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        button.tintColor = UIColor.label
        return button
    }
}
