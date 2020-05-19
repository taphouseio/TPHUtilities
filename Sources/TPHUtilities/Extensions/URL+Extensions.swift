//
//  URL+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 3/27/20.
//

import Foundation

extension URL {
    public init?(string: String?) {
        guard let text = string, let url = URL(string: text) else {
            return nil
        }

        self = url
    }
}
