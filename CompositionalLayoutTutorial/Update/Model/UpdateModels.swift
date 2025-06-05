import Foundation

struct HomeSection: Codable, Hashable {
    var weeklySection: WeeklySection?
    var rankingSection: RankingSection?
    var previewSection: PreviewSection?
    var titleListSection: TitleListSection?
    var bannerSection: BannerSection?
}

struct WeeklySection: Codable, Hashable {
    var contents: [WeeklyContent]
}

struct RankingSection: Codable, Hashable {
    var rankingTab: [RankingTab]
}

struct PreviewSection: Codable, Hashable {
    var previewTabs: [PreviewTab]
}

struct PreviewTab: Codable, Hashable {
    var tabType: Language
    var chapterPagesList: ChapterPageList
}

struct TitleListSection: Codable, Hashable {
    var titleList: TitleList
}

struct BannerSection: Codable, Hashable {
    var banners: [Banner]
}

struct WeeklyContent: Codable, Hashable {
    var isUpdated: Bool
    var updatedTimeStamp: UInt32
    var contentItems: [WeeklyContentItem]
    
    var updatedDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(updatedTimeStamp))
    }
}

enum WeeklyContentItem: Codable, Hashable {
    case latestUpdate(UInt32)
    case prBanner(Banner)
    case mvBanner(MVBanner)
    case titleGroup(TitleGroup)
    case carouselBanner(CarouselBanner)
    case minorLanguageBanner(MinorLanguageBanner)
}

struct MVBanner: Codable, Hashable {
    var imageURL: URL
    var titleGroups: OriginalTitleGroup
}

struct TitleGroup: Codable, Hashable {
    var originalTitleGroup: [OriginalTitleGroup]
}

struct OriginalTitleGroup: Codable, Hashable {
    var titles: [Title]
    var title: String
    var chapterNumber: String
    var viewCount: Int
    var titleUpdateStatus: BadgeType
    var chapterStartTime: UInt32

    var formattedViewCount: String {
        if viewCount >= 1_000_000 {
            return String(format: "%.1fM", Double(viewCount) / 1_000_000)
        } else if viewCount >= 1_000 {
            return String(format: "%.1fK", Double(viewCount) / 1_000)
        } else {
            return "\(viewCount)"
        }
    }
}

struct CarouselBanner: Codable, Hashable {
    var banners: [Banner]
}

struct MinorLanguageBanner: Codable, Hashable {
    var titleGroups: OriginalTitleGroup
}

struct RankingTab: Codable, Hashable {
    var tabType: RankingCategoryType
    var titleRankingGroup: [TitleRankingGroup]
}

struct TitleRankingGroup: Codable, Hashable {
    var titles: [Title]
}

struct ChapterPageList: Codable, Hashable {
    var listName: String
    var chapterPages: [ChapterPages]
}

struct ChapterPages: Codable, Hashable {
    var name: String
    var author: String
    var favoriteImageURL: URL
    var pages: [Page]
}

struct Page: Codable, Hashable {
    var mangaPage: MangaPage
    var bannerList: [Banner]?

    struct MangaPage: Codable, Hashable {
        var imageURL: URL
    }
}

struct Title: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let author: String
    let portraitImageURL: URL
    let landscapeImageURL: URL
    let viewCount: Int
    let languages: [Language]
    let badgeType: BadgeType
    
    var formattedViewCount: String {
        if viewCount >= 1_000_000 {
            return String(format: "%.1fM", Double(viewCount) / 1_000_000)
        } else if viewCount >= 1_000 {
            return String(format: "%.1fK", Double(viewCount) / 1_000)
        } else {
            return "\(viewCount)"
        }
    }
}

struct Banner: Codable, Hashable {
    var id = UUID()
    let imageURL: URL
    let linkURL: URL?
}

struct TitleList: Codable, Hashable {
    let name: String
    let titles: [Title]
}

enum BadgeType: String, Codable, Hashable {
    case up = "UP"
    case new = "NEW"
    case reedition = "REEDITION"
    case ourPicks = "OUR_PICKS"
    case none
}

enum Language: String, Codable, Hashable {
    case english = "EN"
    case spanish = "ES"
    case french = "FR"
    case indonesian = "ID"
    case portuguese_brazil = "PT-BR"
    case russian = "RU"
    case thai = "TH"
    case german = "DE"
    case italian = "IT"
    case vietnamese = "VI"
}

enum dayOfWeek: Int, CaseIterable, Hashable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var displayName: String {
        switch self {
        case .monday: return "MON"
        case .tuesday: return "TUE"
        case .wednesday: return "WED"
        case .thursday: return "THU"
        case .friday: return "FRI"
        case .saturday: return "SAT"
        case .sunday: return "SUN"
        }
    }

    var isToday: Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        // Calendar.currentでは日曜日が1、土曜日が7
        // このenumでは月曜日が0、日曜日が6
        let mappedToday = today == 1 ? 6 : today - 2
        return self.rawValue == mappedToday
    }
}
