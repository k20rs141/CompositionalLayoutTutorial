import Foundation

enum UpdateSectionType: Int, CaseIterable, Hashable {
    case header
    case weekly
    case ranking
    case preview
    case titleList
    case banner
}

enum UpdateSectionItem: Hashable {
    case header
    case weekly(WeeklyContent)
    case ranking(TitleRankingGroup)
    case preview(ChapterPageList)
    case titleList(Title)
    case banner(Banner)
}

enum WeeklyContentSection: Hashable {
    case prBanner
    case mvBanner
    case titleGroup
    case carouselBanners
    case minorLanguageBanner
}

enum RankingCategoryType: Int, CaseIterable {
    case hottest
    case trending
    case completed
    
    var displayName: String {
        switch self {
        case .hottest: return "Hottest"
        case .trending: return "Trending"
        case .completed: return "Completed"
        }
    }
} 
