//
//  APIError.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

enum APIError: Error {
    case networkError
    case pointMismatch
    case contentsNotAvailable
    case forceUpdate
    case unknownError
    case maintenanceError
    case protoParseError(Error)
    case unRegister
    case canNotPost
}
