import Foundation
import Combine

class UpdateViewModel {
    // 出力用のパブリッシャー
    let weeklySectionPublisher = PassthroughSubject<WeeklySection, Never>()
    let rankingSectionPublisher = PassthroughSubject<RankingSection, Never>()
    let previewSectionPublisher = PassthroughSubject<PreviewSection, Never>()
    let titleListSectionPublisher = PassthroughSubject<TitleListSection, Never>()
    let bannerSectionPublisher = PassthroughSubject<BannerSection, Never>()
    let selectedDayPublisher = CurrentValueSubject<dayOfWeek, Never>(.monday)
    let isLoadingPublisher = CurrentValueSubject<Bool, Never>(false)
    let errorPublisher = PassthroughSubject<Error, Never>()
    
    // 内部状態管理
    private var weeklySection: WeeklySection?
    private var rankingSection: RankingSection?
    private var previewSection: PreviewSection?
    private var titleListSection: TitleListSection?
    private var bannerSection: BannerSection?
    private var cancellables = Set<AnyCancellable>()
    
    // 初期化
    init() {
        // 曜日の変更を監視
        selectedDayPublisher
            .sink { [weak self] day in
                self?.loadContentsIfNeeded(for: day)
            }
            .store(in: &cancellables)
    }
    
    // 曜日を選択
    func selectDay(_ day: dayOfWeek) {
        selectedDayPublisher.send(day)
    }
    
    // 曜日のコンテンツがすでに読み込まれているか確認
    func isWeeklyContentLoaded() -> Bool {
        return weeklySection != nil
    }
    
    // 指定した曜日のデータが必要であれば読み込む
    private func loadContentsIfNeeded(for day: dayOfWeek) {
        guard !isWeeklyContentLoaded() else { return }
        
        isLoadingPublisher.send(true)
        
        // 実際のAPIコールをシミュレート（実装時はAPI.fetchWeeklySectionなど実際のAPI呼び出しに置き換え）
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // モックデータ作成（実際の実装ではAPI呼び出し）
            let weeklySection = self.createMockWeeklySection(for: day)
            
            DispatchQueue.main.async {
                self.weeklySection = weeklySection
                self.weeklySectionPublisher.send(weeklySection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
    
    // ランキングを読み込む
    func loadRankings() {
        isLoadingPublisher.send(true)
        
        // 実際のAPIコールをシミュレート
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // モックランキングデータ作成
            let rankingSection = self.createMockRankingSection()
            
            DispatchQueue.main.async {
                self.rankingSection = rankingSection
                self.rankingSectionPublisher.send(rankingSection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
    
    // プレビューコンテンツを読み込む
    func loadPreviews() {
        isLoadingPublisher.send(true)
        
        // 実際のAPIコールをシミュレート
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // モックプレビューデータ作成
            let previewSection = self.createMockPreviewSection()
            
            DispatchQueue.main.async {
                self.previewSection = previewSection
                self.previewSectionPublisher.send(previewSection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
    
    // タイトルリストを読み込む
    func loadTitleList() {
        isLoadingPublisher.send(true)
        
        // 実際のAPIコールをシミュレート
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // モックタイトルリストデータ作成
            let titleListSection = self.createMockTitleListSection()
            
            DispatchQueue.main.async {
                self.titleListSection = titleListSection
                self.titleListSectionPublisher.send(titleListSection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
    
    // バナーセクションを読み込む
    func loadBanners() {
        isLoadingPublisher.send(true)
        
        // 実際のAPIコールをシミュレート
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // モックバナーデータ作成
            let bannerSection = self.createMockBannerSection()
            
            DispatchQueue.main.async {
                self.bannerSection = bannerSection
                self.bannerSectionPublisher.send(bannerSection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
}

// MARK: - モックデータ生成ヘルパー
extension UpdateViewModel {
    private func createMockWeeklySection(for day: dayOfWeek) -> WeeklySection {
        // 各曜日のコンテンツを作成
        let weeklyContents = [createMockWeeklyContent(for: day)]
        
        return WeeklySection(contents: weeklyContents)
    }
    
    private func createMockWeeklyContent(for day: dayOfWeek) -> WeeklyContent {
        // コンテンツアイテムを生成
        var contentItems: [ContentItem] = []
        
        // MVバナー
        if let mvBanner = createMockMVBanner(for: day) {
            contentItems.append(.mvBanner(mvBanner))
        }
        
        // PRバナー（月曜日のみ）
        if day == .monday {
            if let prBanner = createMockPRBanner() {
                contentItems.append(.prBanner(prBanner))
            }
        }
        
        // タイトルグループ
        let titleGroup = createMockTitleGroup()
        contentItems.append(.titleGroup(titleGroup))
        
        // カルーセルバナー
        let carouselBanner = createMockCarouselBanner()
        contentItems.append(.carouselBanners(carouselBanner))
        
        // マイナー言語バナー（水曜日のみ）
        if day == .wednesday {
            let minorLanguageBanner = createMockMinorLanguageBanner()
            contentItems.append(.minorLanguageBanner(minorLanguageBanner))
        }
        
        return WeeklyContent(
            isUpdated: day.isToday,
            updatedTimeStamp: UInt32(Date().timeIntervalSince1970),
            contentItems: contentItems
        )
    }
    
    private func createMockMVBanner(for day: dayOfWeek) -> MVBanner? {
        let titles = createMockTitles(count: 3)
        let originalTitleGroup = OriginalTitleGroup(
            titles: titles,
            title: "MVバナータイトル",
            chapterNumber: "Chapter 1",
            viewCount: 10000,
            titleUpdateStatus: .up,
            chapterStartTime: UInt32(Date().timeIntervalSince1970)
        )
        
        return MVBanner(
            imageURL: URL(string: "https://example.com/banner_\(day.rawValue).jpg")!,
            titleGroups: originalTitleGroup
        )
    }
    
    private func createMockPRBanner() -> Banner? {
        return Banner(
            imageURL: URL(string: "https://example.com/pr_banner.jpg")!,
            linkURL: URL(string: "https://example.com/promotion")
        )
    }
    
    private func createMockTitleGroup() -> TitleGroup {
        let titleGroups = (0..<3).map { _ in
            OriginalTitleGroup(
                titles: createMockTitles(count: 5),
                title: "おすすめタイトル",
                chapterNumber: "Chapter 1",
                viewCount: Int.random(in: 10000...5000000),
                titleUpdateStatus: .up,
                chapterStartTime: UInt32(Date().timeIntervalSince1970)
            )
        }
        
        return TitleGroup(titleGroups: titleGroups)
    }
    
    private func createMockCarouselBanner() -> CarouselBanner {
        let banners = (0..<3).map { index in
            Banner(
                imageURL: URL(string: "https://example.com/carousel_\(index).jpg")!,
                linkURL: URL(string: "https://example.com/campaign/\(index)")
            )
        }
        
        return CarouselBanner(banners: banners)
    }
    
    private func createMockMinorLanguageBanner() -> MinorLanguageBanner {
        return MinorLanguageBanner(titles: createMockTitles(count: 6))
    }
    
    private func createMockRankingSection() -> RankingSection {
        let rankedTitles = (0..<3).map { categoryIndex in
            TitleRankingGroup(
                titles: createMockTitles(count: 5)
            )
        }
        
        return RankingSection(rankedTitles: rankedTitles)
    }
    
    private func createMockPreviewSection() -> PreviewSection {
        let pages = (0..<4).map { index in
            ChapterPage(
                title: createMockTitles(count: 1)[0],
                imageURLs: (1...3).map { pageIndex in
                    URL(string: "https://example.com/preview_\(index + 1)_page_\(pageIndex).jpg")!
                }
            )
        }
        
        return PreviewSection(chapterPagesList: ChapterPageList(pages: pages))
    }
    
    private func createMockTitleListSection() -> TitleListSection {
        let titles = createMockTitles(count: 12)
        return TitleListSection(titleList: TitleList(titles: titles, name: "おすすめタイトル"))
    }
    
    private func createMockBannerSection() -> BannerSection {
        let banners = (0..<2).map { index in
            Banner(
                imageURL: URL(string: "https://example.com/banner_\(index).jpg")!,
                linkURL: URL(string: "https://example.com/banner/\(index)")
            )
        }
        
        return BannerSection(banners: banners)
    }
    
    private func createMockTitles(count: Int) -> [Title] {
        return (0..<count).map { index in
            Title(
                id: "title_\(index)",
                title: "マンガタイトル \(index + 1)",
                thumbnailURL: URL(string: "https://example.com/manga_\(index + 1).jpg")!,
                chapterNumber: 100 + index,
                viewCount: Int.random(in: 10000...5000000),
                badgeType: index % 5 == 0 ? .up : .none,
                languages: ["en", "ja", "es"].shuffled().prefix(Int.random(in: 1...3)).map { $0 }
            )
        }
    }
} 
