//
//  Banner.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

struct Banners: Codable, Hashable {
    let id: Int
    let title: String
    let imageUrl: String
    let dateString: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
