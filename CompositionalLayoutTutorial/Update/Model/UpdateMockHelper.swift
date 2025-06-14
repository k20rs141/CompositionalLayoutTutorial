//
//  UpdateMockHelper.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/21.
//

import Foundation

// MARK: - モックデータ生成ヘルパー
extension UpdateViewModel {
     func createMockHomeSection() -> HomeSection {
        return HomeSection(
            weeklySection: createMockWeeklySection(for: selectedDayPublisher.value),
            rankingSection: createMockRankingSection(),
            previewSection: createMockPreviewSection(),
            titleListSection: createMockTitleListSection(),
            bannerSection: createMockBannerSection()
        )
    }

    func createMockWeeklySection(for day: dayOfWeek) -> WeeklySection {
        // 全曜日分のコンテンツを作成
        let weeklyContents = dayOfWeek.allCases.map { createMockWeeklyContent(for: $0) }
        return WeeklySection(contents: weeklyContents)
    }

    func createMockWeeklyContent(for day: dayOfWeek) -> WeeklyContent {
        var contentItems: [WeeklyContentItem] = []
        let timestampForDay: UInt32
        switch day {
        case .monday:
            timestampForDay = 1752418800 // 2025/07/14
        case .tuesday:
            timestampForDay = 1752505200 // 2025/07/15
        case .wednesday:
            timestampForDay = 1751986800 // 2025/07/09
        case .thursday:
            timestampForDay = 1752073200 // 2025/07/10
        case .friday:
            timestampForDay = 1752159600 // 2025/07/11
        case .saturday:
            timestampForDay = 1752246000 // 2025/07/12
        case .sunday:
            timestampForDay = 1752332400 // 2025/07/13
        }

        contentItems.append(.latestUpdate(timestampForDay))
        
        if day == .tuesday {
            if let prBanner = createMockPRBanner() {
                contentItems.append(.prBanner(prBanner))
            }
        }
        if let mvBanner = createMockMVBanner(for: day) {
            contentItems.append(.mvBanner(mvBanner))
        }
        let titleGroup = createMockTitleGroup()
        contentItems.append(.titleGroup(titleGroup))

        let carouselBanner = createMockCarouselBanner()
        contentItems.append(.carouselBanner(carouselBanner))

        let minorLanguageBanner = createMockMinorLanguageBanner()
        contentItems.append(.minorLanguageBanner(minorLanguageBanner))

        return WeeklyContent(
            isUpdated: day.isToday,
            updatedTimeStamp: timestampForDay,
            contentItems: contentItems
        )
    }
    
    func createMockMVBanner(for day: dayOfWeek) -> MVBanner? {
        let titles = createMockTitles(count: 1)
        let originalTitleGroup = OriginalTitleGroup(
            titles: titles,
            title: "MVバナータイトル",
            chapterNumber: "#123",
            viewCount: 10000,
            titleUpdateStatus: .ourPicks,
            chapterStartTime: UInt32(Date().timeIntervalSince1970)
        )
        return MVBanner(
            imageURL: URL(string: "https://placehold.jp/3d4070/ffffff/380x190.png")!,
            titleGroups: originalTitleGroup
        )
    }

    func createMockPRBanner() -> Banner? {
        return Banner(
            imageURL: URL(string: "https://placehold.jp/3d4070/ffffff/380x215.png")!,
            linkURL: URL(string: "https://www.apple.com")
        )
    }

    func createMockTitleGroup() -> TitleGroup {
        let titleGroups = (0..<7).map { index in
            OriginalTitleGroup(
                titles: createMockTitles(count: 1),
                title: "タイトルグループ",
                chapterNumber: "#\(index)",
                viewCount: Int.random(in: 10000...5000000),
                titleUpdateStatus: .up,
                chapterStartTime: UInt32(Date().timeIntervalSince1970)
            )
        }
        return TitleGroup(originalTitleGroup: titleGroups)
    }

    func createMockCarouselBanner() -> CarouselBanner {
        let banners = (0..<4).map { index in
            Banner(
                imageURL: URL(string: "https://placehold.jp/3d4070/ffffff/380x145.png")!,
                linkURL: URL(string: "https://www.apple.com")
            )
        }
        return CarouselBanner(banners: banners)
    }

    func createMockMinorLanguageBanner() -> MinorLanguageBanner {
        let originalTitleGroup = OriginalTitleGroup(
            titles: createMockTitles(count: 4),
            title: "MVバナータイトル",
            chapterNumber: "#123",
            viewCount: 10000,
            titleUpdateStatus: .up,
            chapterStartTime: UInt32(Date().timeIntervalSince1970)
        )
        return MinorLanguageBanner(titleGroups: originalTitleGroup)
    }

    func createMockRankingSection() -> RankingSection {
        let rankingTabs = RankingCategoryType.allCases.map { categoryType in
            RankingTab(
                tabType: categoryType,
                titleRankingGroup: [
                    TitleRankingGroup(titles: createMockTitles(count: 5))
                ]
            )
        }
        return RankingSection(rankingTab: rankingTabs)
    }

    func createMockPreviewSection() -> PreviewSection {
        return PreviewSection(previewTabs: createMockPreviewTabs(count: 2))
    }

    func createMockPreviewTabs(count: Int) -> [PreviewTab] {
        let previewTab = (0..<count).map { index in
            PreviewTab(
                tabType: index % 2 == 0 ? .english : .italian,
                chapterPagesList: ChapterPageList(
                    listName: "Preview Section",
                    chapterPages: createChapterPages(count: 4)
                )
            )
        }
        return previewTab
    }

    func createChapterPages(count: Int) -> [ChapterPages] {
        let chapterPages = (0..<count).map { index in
            ChapterPages(
                name: count % 2 == 0 ? "Chainsaw Man" : "One Piece",
                author: count % 2 == 0 ? "Tatsuki Fujimoto" : "Eiichiro Oda",
                favoriteImageURL: URL(string: "https://placehold.jp/3d4070/ffffff/300x450.png")!,
                pages: createMockPages()
            )
        }
        return chapterPages
    }

    func createMockPages() -> [Page] {
        let pages = (0..<5).map { index in
            Page(
                mangaPage: .init(
                    imageURL: URL(string: "https://placehold.jp/3d4070/ffffff/260x380.png")!
                ),
                bannerList: nil
            )
        }
        return pages
    }

    func createMockTitleListSection() -> TitleListSection {
        let titles = createMockTitles(count: 12)
        let titleList = TitleList(name: "おすすめタイトル", titles: titles)
        return TitleListSection(titleList: titleList)
    }

    func createMockBannerSection() -> BannerSection {
        let banners = (0..<4).map { index in
            Banner(
                imageURL: URL(string: "https://placehold.jp/3d4070/ffffff/382x120.png?id=\(index)")!,
                linkURL: URL(string: "https://www.apple.com")
            )
        }
        return BannerSection(banners: banners)
    }

    func createMockTitles(count: Int) -> [Title] {
        return (0..<count).map { index in
            Title(
                id: "title_\(index)",
                name: "マンガタイトル \(index + 1)",
                author: "作者名 \(index + 1)",
                portraitImageURL: URL(string: "https://placehold.jp/3d4070/ffffff/300x450.png")!,
                landscapeImageURL: URL(string: "https://placehold.jp/3d4070/ffffff/450x300.png")!,
                viewCount: Int.random(in: 10000...5000000),
                languages: [.english, .spanish, .french].prefix(Int.random(in: 1...3)).map { $0 },
                badgeType: index % 5 == 0 ? .up : (index % 5 == 1 ? .new : .none)
            )
        }
    }
}
