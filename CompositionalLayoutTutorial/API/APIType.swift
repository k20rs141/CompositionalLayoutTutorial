//
//  APIType.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation
import Moya

enum Endpoint {
    case banner
    case interview
    case recentKeywords
    case newArrivalArticles
    case regularArticles
}

extension Endpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost:3000/api/mock/v1/gourmet") else { fatalError() }
        return url
    }

    var path: String {
        switch self {
        case .banner:
            return "/featured_banners"
        case .interview:
            return "/featured_interviews"
        case .recentKeywords:
            return "/keywords"
        case .newArrivalArticles:
            return "/new_arrivals"
        case .regularArticles:
            return "/articles"
        }
    }

    var method: Moya.Method {
        switch self {
        case .banner, .interview, .recentKeywords, .newArrivalArticles, .regularArticles:
            return .get
        }
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String : String]? {
        nil
    }
}
