//
//  ImagePicker.swift
//  Utilities
//
//  Created by Jared Sorge on 1/17/20.
//

import MobileCoreServices
import UIKit

public protocol ImagePickerDelegate: AnyObject {
    /// Called when an image is selected from the picker.
    /// - Parameters:
    ///   - image: The image that was picked.
    ///   - sender: The image picker responsible.
    func didSelectImage(_ image: UIImage, from sender: ImagePicker)
}

/// This class can handle presenting an image picker and dealing with the resulting taken or picked image
public final class ImagePicker: NSObject {
    private weak var delegate: ImagePickerDelegate?
    private let shouldSaveToCameraRoll: Bool
    private let allowEditing: Bool
    private var presentingViewController: UIViewController?

    public var deviceHasCamera: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /// Creates an instance
    /// - Parameters:
    ///   - delegate: The delegate
    ///   - shouldSaveToCameraRoll: True if images taken with the camera should save to the camera roll
    ///   - allowEditing: True if taken or picked images should be editable
    public init(delegate: ImagePickerDelegate?, shouldSaveToCameraRoll: Bool, allowEditing: Bool) {
        self.delegate = delegate
        self.shouldSaveToCameraRoll = shouldSaveToCameraRoll
        self.allowEditing = allowEditing

        super.init()
    }

    /// Show the camera
    /// - Parameter sender: The view controller to present the camera
    public func showCamera(from sender: UIViewController) {
        showImagePicker(sourceType: .camera, from: sender)
    }

    /// Show the image picker
    /// - Parameter sender: The view controller to present the picker
    public func showImagePicker(from sender: UIViewController) {
        showImagePicker(sourceType: .photoLibrary, from: sender)
    }

    /// If the device has a camera available, an action sheet will be presented with the option to take a picture
    /// with the camera or pick an image from the gallery. If no camera is available, the gallery will just be
    /// presented without any prompting.
    /// - Parameter sender: The view controller to present the camera or gallery picker
    public func showSourcePickerAndPresent(from sender: UIViewController) {
        guard deviceHasCamera else {
            showImagePicker(from: sender)
            return
        }

        let cameraAction = UIAlertAction(title: "Take Picture", style: .default, handler: { [weak self] _ in
            self?.showCamera(from: sender)
        })

        let pickerAction = UIAlertAction(title: "Choose from library", style: .default, handler: { [weak self] _ in
            self?.showImagePicker(from: sender)
        })

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(pickerAction)
        actionSheet.addAction(.cancel)

        sender.present(actionSheet, animated: true, completion: nil)
    }

    private func showImagePicker(sourceType: UIImagePickerController.SourceType, from sender: UIViewController) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = allowEditing
        picker.sourceType = sourceType

        presentingViewController = sender

        sender.present(picker, animated: true, completion: nil)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image: UIImage
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let takenImage = info[.originalImage] as? UIImage {
            image = takenImage
        } else {
            return
        }

        if shouldSaveToCameraRoll && picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }

        delegate?.didSelectImage(image, from: self)
    }
}
