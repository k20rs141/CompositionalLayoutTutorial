//
//  InterView.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

struct Interviews: Codable, Hashable {
    let id: Int
    let profileName: String
    let dateString: String
    let imageUrl: String
    let title: String
    let description: String
    let tags: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
