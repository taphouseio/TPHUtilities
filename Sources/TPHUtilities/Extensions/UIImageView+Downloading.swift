//
//  UIImageView+Downloading.swift
//  Utilities
//
//  Created by Jared Sorge on 2/3/20.
//

import UIKit

extension UIImageView {
    public func setImage(url: URL, placeholder: UIImage?) {
        image = placeholder

        if let image = ImageCache.shared.fetchImage(originallyFrom: url) {
            self.image = image
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }

            ImageCache.shared.storeImage(image, from: url)

            DispatchQueue.main.async {
                self.image = image
            }
        }

        task.resume()
    }
}
