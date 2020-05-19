//
//  Collection+Extensions.swift
//  Utilities
//
//  Created by Jared Sorge on 2/24/20.
//

extension Collection {
    public subscript(safe index: Index) -> Iterator.Element? {
        guard startIndex <= index, index < endIndex else { return nil }
        return self[index]
    }
}
