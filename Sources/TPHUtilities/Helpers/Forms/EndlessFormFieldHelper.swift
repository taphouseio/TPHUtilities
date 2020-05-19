//
//  FormFieldHelper.swift
//  Utilities
//
//  Created by Jared Sorge on 4/10/20.
//

import UIKit

/// This class organizes an array of form fields. When asked for the next field after the end or before the beginning
/// field, this class will return either the beginning or the end field (next/previous will always return a field).
public final class EndlessFormFieldHelper {
    private let fields: [FormField]

    /// The currently selected text field
    public private(set) var currentField: FormField
    /// The currently selected responder
    public var currentResponder: UIResponder { return currentField.responder }

    /// Creates an instance. The field count must be > 0 or else nil will be returned.
    ///
    /// - parameter fields: The fields to be managed
    /// - parameter endless: Whether or not to indicate that a field is the beginning or the end
    public init?(fields: [FormField]) {
        guard fields.count > 0 else {
            return nil
        }

        self.fields = fields
        // Using the index accessor to avoid `.first`'s optionality
        currentField = fields[0]
    }

    /// Fetches the field after the given field. If the input is the last field given in the form, then
    /// the first field will be returned.
    ///
    /// - parameter field: The field currently active
    ///
    /// - returns: The next field, or the first one depending on where the field parameter falls in the form.
    public func nextField(after field: FormField) -> FormField {
        let newIndex = indexOf(field: field)
        return advanceField(to: newIndex + 1)
    }

    /// Fetches the field before the given field. If the input is the first field given in the form, then
    /// the last field will be returned.
    ///
    /// - parameter field: The field currently active
    ///
    /// - returns: The previous field, or the last one depending on where the field parameter falls in the
    ///            form.
    public func previousField(before field: FormField) -> FormField {
        let newIndex = indexOf(field: field)
        return advanceField(to: newIndex - 1)
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

    private func advanceField(to index: Int) -> FormField {
        // Using index accessors below to avoid `.first` and `.last`'s optionality
        if let nextField = fields[safe: index] {
            currentField = nextField
        } else if index >= fields.count {
            // Going forward past the bounds of the array should go to the first field
            currentField = fields[0]
        } else {
            // Going backwards past the bounds of the array should go to the last field
            currentField = fields[fields.count - 1]
        }

        return currentField
    }

    private func indexOf(field: FormField) -> Int {
        guard let index = fields.firstIndex(of: field) else {
            fatalError("There should be an index for any stored fields")
        }

        return index
    }
}
