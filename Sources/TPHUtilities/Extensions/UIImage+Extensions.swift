//
//  UIImage+Resizing.swift
//  Utilities
//
//  Created by Jared Sorge on 1/27/20.
//
// Adapted from https://github.com/AliSoftware/UIImage-Resize/blob/master/UIImage%2BResize.m

import UIKit

extension UIImage {
    public static func makeFrom(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(rect)
        }

        guard let cgImage = image.cgImage else {
            return nil
        }

        return UIImage(cgImage: cgImage).withRenderingMode(.alwaysOriginal)
    }

    public func resized(to size: CGSize) -> UIImage? {
        guard let imageRef = cgImage else {
            return nil
        }

        let sourceSize = CGSize(width: imageRef.width, height: imageRef.height)

        var destinationSize = size
        guard destinationSize != sourceSize else {
            return self
        }

        let scaleRatio = destinationSize.width / sourceSize.width
        let orientation = imageOrientation
        var transform = CGAffineTransform.identity

        switch orientation {
        case .up:
            break

        case .upMirrored:
            transform = CGAffineTransform(translationX: sourceSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)

        case .down:
            transform = CGAffineTransform(translationX: sourceSize.width, y: sourceSize.height)
            transform = transform.rotated(by: .pi)

        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: sourceSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)

        case .left:
            destinationSize = destinationSize.flippingWidthAndHeight()
            transform = CGAffineTransform(translationX: 0.0, y: sourceSize.width)
            transform = transform.rotated(by: 3.0 * CGFloat.pi / 2)

        case .leftMirrored:
            destinationSize = destinationSize.flippingWidthAndHeight()
            transform = CGAffineTransform(translationX: sourceSize.height, y: sourceSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * CGFloat.pi / 2)

        case .right:
            destinationSize = destinationSize.flippingWidthAndHeight()
            transform = CGAffineTransform(translationX: sourceSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat.pi / 2)

        case .rightMirrored:
            destinationSize = destinationSize.flippingWidthAndHeight()
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat.pi / 2)

        @unknown default:
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: destinationSize)
        let image = renderer.image { context in
            if orientation == .right || orientation == .left {
                context.cgContext.ctm.scaledBy(x: -scaleRatio, y: scaleRatio)
                context.cgContext.ctm.translatedBy(x: -sourceSize.height, y: 0)
            } else {
                context.cgContext.ctm.scaledBy(x: scaleRatio, y: -scaleRatio)
                context.cgContext.ctm.translatedBy(x: 0, y: -sourceSize.height)
            }

            context.cgContext.concatenate(transform)
            self.draw(in: CGRect(origin: .zero, size: destinationSize))
        }

        return image
    }

    public func resizedToFit(in newSize: CGSize, scaleIfSmaller: Bool) -> UIImage? {
        guard let imageRef = cgImage else {
            return nil
        }

        let sourceSize = CGSize(width: imageRef.width, height: imageRef.height)

        var boundingSize = newSize
        let orientation = imageOrientation

        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            boundingSize = boundingSize.flippingWidthAndHeight()

        default:
            break
        }

        let destinationSize: CGSize

        if scaleIfSmaller == false, sourceSize.width < boundingSize.width, sourceSize.height < boundingSize.height {
            destinationSize = sourceSize
        } else {
            let widthRatio = boundingSize.width / sourceSize.width
            let heightRatio = boundingSize.height / sourceSize.height

            if widthRatio < heightRatio {
                destinationSize = CGSize(width: boundingSize.width, height: floor(sourceSize.height * widthRatio))
            } else {
                destinationSize = CGSize(width: floor(sourceSize.width * heightRatio), height: boundingSize.height)
            }
        }

        return resized(to: destinationSize)
    }
}

private extension CGSize {
    func flippingWidthAndHeight() -> CGSize {
        return CGSize(width: height, height: width)
    }
}
