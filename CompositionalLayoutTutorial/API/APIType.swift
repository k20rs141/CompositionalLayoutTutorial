//
//  APIType.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation
import Moya

enum Endpoint {
    case homeSection
}

extension Endpoint: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://localhost:3000/api/mock/v1") else { fatalError() }
        return url
    }

    var path: String {
        switch self {
        case .homeSection:
            return "/home"
        }
    }

    var method: Moya.Method {
        switch self {
        case .homeSection:
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
