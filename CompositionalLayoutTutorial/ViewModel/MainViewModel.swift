//
//  MainViewModel.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation

final class MainViewModel {
    private let apiProvider: APIProviderProtocol
    var banners: [Banners] = []
    var interviews: [Interviews] = []
    var recentKeywords: [RecentKeywords] = []
    var newArrivalArticles: [NewArrivalArticles] = []
    var regularArticles: [RegularArticles] = []

    init(apiProvider: APIProviderProtocol = APIProvider.shared) {
        self.apiProvider = apiProvider
    }

    func getBanners() {
        apiProvider.getBanners()
            .then { banners in
                print(banners)
                self.banners = banners
            }
            .catch { error in
                print(error)
            }
    }

    func getInterviews() {
        apiProvider.getInterviews()
            .then { interviews in
                print(interviews)
                self.interviews = interviews
            }
            .catch { error in
                print(error)
            }
    }

    func getRecentKeywords() {
        apiProvider.getRecentKeywords()
            .then { recentKeywords in
                print(recentKeywords)
                self.recentKeywords = recentKeywords
            }
            .catch { error in
                print(error)
            }
    }

    func getNewArrivalArticles() {
        apiProvider.getNewArrivalArticles()
            .then { newArrivalArticles in
                print(newArrivalArticles)
                self.newArrivalArticles = newArrivalArticles
            }
            .catch { error in
                print(error)
            }
    }

    func getRegularArticles() {
        apiProvider.getRegularArticles()
            .then { regularArticles in
                print(regularArticles)
                self.regularArticles = regularArticles
            }
            .catch { error in
                print(error)
            }
    }
}
