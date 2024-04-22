//
//  RecentryKeyword.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

struct RecentKeywords: Codable, Hashable {
    let id: Int
    let keyword: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
