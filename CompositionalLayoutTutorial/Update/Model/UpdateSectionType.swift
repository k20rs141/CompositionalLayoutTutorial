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
    case ranking(TitleRankingGroup, Title, Int)
    case preview(ChapterPageList)
    case titleList(Title)
    case banner(Banner)
}

enum WeeklyContentSection: Hashable {
    case latestUpdate
    case prBanner
    case mvBanner
    case titleGroup
    case carouselBanners
    case minorLanguageBanner
}

enum WeeklySectionItem: Hashable {
    case latestUpdate(UInt32)
    case prBanner(Banner)
    case mvBanner(MVBanner)
    case titleGroup(OriginalTitleGroup)
    case carouselBanner(Banner)
    case minorLanguageBanner(MinorLanguageBanner)
} 

enum RankingCategoryType: Int, Codable, CaseIterable {
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
