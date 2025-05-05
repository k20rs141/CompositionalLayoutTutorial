//
//  APIProvider.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation
import Moya
import Promises

protocol APIProviderProtocol {
    func getBanners() -> Promise<[Banners]>
    func getInterviews() -> Promise<[Interviews]>
    func getRecentKeywords() -> Promise<[RecentKeywords]>
    func getNewMenuItems() -> Promise<[NewMenuItems]>
    func getRecommendedArticles() -> Promise<[RecommendedArticles]>
}

final class APIProvider: MoyaProvider<Endpoint> {
    static let shared = APIProvider()

    // MARK: - Promise
    func api<T: Codable>(dataType: T.Type, target: Endpoint) -> Promise<[T]> {
        .init { fulfill, reject in
            self.request(target) { result in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                switch result {
                case let .success(response):
                    switch response.statusCode {
                    case 400:
                        return reject(APIError.unknownError)
                    case 401:
                        return reject(APIError.unRegister)
                    case 402:
                        return reject(APIError.pointMismatch)
                    case 403:
                        return reject(APIError.canNotPost)
                    case 426:
                        return reject(APIError.forceUpdate)
                    case 500:
                        return reject(APIError.unknownError)
                    case 503:
                        return reject(APIError.maintenanceError)
                    default:
                        do {
                            let data = try decoder.decode([T].self, from: response.data)
                            fulfill(data)
                        } catch(let error) {
                            print(target.path)
                            reject(error)
                        }
                    }
                case let .failure(error):
                    reject(error)
                }
            }
        }
    }
}

extension APIProvider: APIProviderProtocol {
    func getBanners() -> Promise<[Banners]> {
        api(dataType: Banners.self, target: .banner)
    }

    func getInterviews() -> Promise<[Interviews]> {
        api(dataType: Interviews.self, target: .interview)
    }

    func getRecentKeywords() -> Promise<[RecentKeywords]> {
        api(dataType: RecentKeywords.self, target: .recentKeywords)
    }

    func getNewMenuItems() -> Promise<[NewMenuItems]> {
        api(dataType: NewMenuItems.self, target: .newMenuItems)
    }

    func getRecommendedArticles() -> Promise<[RecommendedArticles]> {
        api(dataType: RecommendedArticles.self, target: .recommendedArticles)
    }
}
