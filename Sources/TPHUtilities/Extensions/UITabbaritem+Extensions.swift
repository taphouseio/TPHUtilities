//
//  UITabbaritem+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 1/11/20.
//

import UIKit

extension UITabBarItem {
    public static func withMarcoAppearance(title: String?, image: UIImage?) -> UITabBarItem {
        let mainImage = image ?? UIImage.makeFrom(color: .clear)
        let item = UITabBarItem(title: title?.uppercased(), image: mainImage, selectedImage: .smallCircle)

        if image == nil {
            item.imageInsets = UIEdgeInsets(top: 40.0, left: 0, bottom: 0, right: 0)
        } else {
            item.imageInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 0, right: 0)
        }

        return item
    }
}

private extension UIImage {
    static var smallCircle: UIImage? {
        return UIImage(systemName: "circle.fill")?.resized(to: CGSize(width: 12, height: 12))
    }
}
