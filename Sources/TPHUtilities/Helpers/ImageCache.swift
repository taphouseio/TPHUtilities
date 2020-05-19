//
//  ImageCache.swift
//  Utilities
//
//  Created by Jared Sorge on 2/4/20.
//

import UIKit

public typealias FileURL = URL

public final class ImageCache {
    private let storagePath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first.unsafelyUnwrapped
        return documentsDirectory
    }()

    public static let shared = ImageCache()

    public func fetchImage(originallyFrom remoteURL: URL) -> UIImage? {
        let filePath = "\(storagePath)/\(remoteURL.sanitizingIntoFileName())"
        let fileURL = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    public func storeImage(_ image: UIImage, from remoteURL: URL) {
        storeImage(image, with: remoteURL.sanitizingIntoFileName())
    }

    public func storeImage(_ image: UIImage, with handle: String) {
        let filePath = "\(storagePath)/\(handle)"
        let data = image.jpegData(compressionQuality: 0.8)
        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
    }
}

private extension URL {
    func sanitizingIntoFileName() -> String {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let filename = components.path.components(separatedBy: "/").last else {
            return UUID().uuidString
        }

        return filename
    }
}
