import Foundation

enum Section: Hashable {
    case weekly(WeeklySection)
    case ranking(RankingSection)
    case preview(PreviewSection)
    case titleList(TitleListSection)
    case banner(BannerSection)
}

struct WeeklySection: Hashable {
    var contents: [WeeklyContent]
}

struct WeeklyContent: Hashable {
    var isUpdated: Bool
    var updatedTimeStamp: UInt32
    var contentItems: [ContentItem]
    
    var updatedDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(updatedTimeStamp))
    }
}

enum ContentItem: Hashable {
    case prBanner(Banner)
    case mvBanner(MVBanner)
    case titleGroup(TitleGroup)
    case carouselBanners(CarouselBanner)
    case minorLanguageBanner(MinorLanguageBanner)
}

struct MVBanner: Hashable {
    var imageURL: URL
    var titleGroups: OriginalTitleGroup
}

struct TitleGroup: Hashable {
    var titleGroups: [OriginalTitleGroup]
}

struct OriginalTitleGroup: Hashable {
    var titles: [Title]
    var title: String
    var chapterNumber: String
    var viewCount: Int
    var titleUpdateStatus: BadgeType
    var chapterStartTime: UInt32
}

struct CarouselBanner: Hashable {
    var banners: [Banner]
}

struct MinorLanguageBanner: Hashable {
    var titles: [Title]
}

struct RankingSection: Hashable {
    var rankedTitles: [TitleRankingGroup]
}

struct TitleRankingGroup: Hashable {
    var titles: [Title]
}

struct PreviewSection: Hashable {
    var chapterPagesList: ChapterPageList
}

struct ChapterPageList: Hashable {
    var pages: [ChapterPage]
}

struct ChapterPage: Hashable {
    var title: Title
    var imageURLs: [URL]
}

struct TitleListSection: Hashable {
    var titleList: TitleList
}

struct BannerSection: Hashable {
    var banners: [Banner]
}

struct Title: Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnailURL: URL
    let chapterNumber: Int
    let viewCount: Int
    let badgeType: BadgeType
    let languages: [String]
    
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

struct Banner: Hashable {
    let imageURL: URL
    let linkURL: URL?
}

struct TitleList: Hashable {
    let titles: [Title]
    let name: String
}

enum BadgeType: String, Hashable {
    case up = "UP"
    case new = "NEW"
    case reedition = "REEDITION"
    case ourPicks = "OUR_PICKS"
    case none
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
