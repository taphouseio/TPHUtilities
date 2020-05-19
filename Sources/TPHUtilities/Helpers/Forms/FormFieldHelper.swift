//
//  FormFieldHelper.swift
//  Utilities
//
//  Created by Jared Sorge on 4/10/20.
//

import UIKit

/// This class organizes an array of form fields.
public final class FormFieldHelper {
    private let fields: [FormField]

    /// The currently selected text field
    public private(set) var currentField: FormField?
    /// The currently selected responder
    public var currentResponder: UIResponder? { return currentField?.responder }

    /// Creates an instance. The field count must be > 0 or else nil will be returned.
    ///
    /// - parameter fields: The fields to be managed
    /// - parameter endless: Whether or not to indicate that a field is the beginning or the end
    public init?(fields: [FormField]) {
        guard fields.count > 0 else {
            return nil
        }

        self.fields = fields
        currentField = fields.first
    }

    /// Fetches the field after the given field.
    ///
    /// - parameter field: The field currently active
    ///
    /// - returns: The next field, if there is one
    public func nextField(after field: FormField) -> FormField? {
        let newIndex = indexOf(field: field)
        currentField = fields[safe: newIndex + 1]
        return currentField
    }

    /// Fetches the field before the given field.
    ///
    /// - parameter field: The field currently active
    ///
    /// - returns: The previous field, if there is one
    public func previousField(before field: FormField) -> FormField? {
        let newIndex = indexOf(field: field)
        currentField = fields[safe: newIndex - 1]
        return currentField
    }

    /// Given a responder, locates the corresponding field if there is one.
    ///
    /// - parameter responder: The responder to search with
    ///
    /// - returns: The field, if one is found corresponding to the responder
    public func field(for responder: UIResponder) -> FormField? {
        return fields.first(where: { $0.responder == responder })
    }

    /// Given a descriptor, locates the corresponding field if there is one.
    ///
    /// - parameter descriptor: The descriptor to search with
    ///
    /// - returns: The field, if one is found corresponding to the descriptor
    public func field(for descriptor: String) -> FormField? {
        return fields.first(where: { $0.descriptor == descriptor })
    }

    private func indexOf(field: FormField) -> Int {
        guard let index = fields.firstIndex(of: field) else {
            fatalError("There should be an index for any stored fields")
        }

        return index
    }
}
