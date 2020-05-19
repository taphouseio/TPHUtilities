//
//  FormField.swift
//  Utilities
//
//  Created by Jared Sorge on 4/10/20.
//

import UIKit

public struct FormField: Equatable {
    /// A string representation of the field (i.e. "model")
    public let descriptor: String
    /// The corresponding responder for that field
    public let responder: UIResponder

    public init(descriptor: String, responder: UIResponder) {
        self.descriptor = descriptor
        self.responder = responder
    }
}
