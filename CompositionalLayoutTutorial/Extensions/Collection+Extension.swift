//
//  Collection+Extension.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/18.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
