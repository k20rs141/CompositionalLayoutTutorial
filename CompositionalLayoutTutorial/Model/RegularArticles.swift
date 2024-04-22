//
//  RegularArticles.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

struct RegularArticles: Codable, Hashable {
    let id: Int
    let title: String
    let summary: String
    let imageUrl: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
