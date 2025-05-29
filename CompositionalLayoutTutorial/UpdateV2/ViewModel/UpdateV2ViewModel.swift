import Foundation
import Combine


enum Section: Int, CaseIterable, Hashable {
    case ranking
    case preview
    case titleList
    case banner
}

enum Item: Hashable {
    case ranking(TitleRankingGroup, Title, Int)
    case preview(ChapterPageList)
    case titleList(Title)
    case banner(Banner)
}

final class UpdateV2ViewModel {
    // 画面全体のデータ
    @Published private(set) var homeSection: HomeSection?
    @Published private(set) var weeklyContents: [WeeklyContent] = []
    @Published private(set) var updateSectionTypes: [Section] = []
    // ランキング・プレビュー・バナー等も同様に@Publishedで管理可能
    let selectedDayIndex = CurrentValueSubject<Int, Never>(0)
    private var cancellables = Set<AnyCancellable>()

    // 曜日切り替え
    func selectDay(index: Int) {
        selectedDayIndex.send(index)
    }

    func loadHomeSection() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let homeSection = UpdateViewModel().createMockHomeSection()

            DispatchQueue.main.async {
                self.homeSection = homeSection
                self.updateSection()
                self.weeklyContents = homeSection.weeklySection?.contents ?? []
            }
        }
    }

    private func updateSection() {
        guard let homeSection = homeSection else { return }

        var sectionTypes: [Section] = []

        if let rankingSection = homeSection.rankingSection, !rankingSection.rankingTab.isEmpty {
            sectionTypes.append(.ranking)
        }
        if let previewSection = homeSection.previewSection,
           !previewSection.chapterPagesList.chapterPages.isEmpty {
            sectionTypes.append(.preview)
        }
        if let titleListSection = homeSection.titleListSection,
           !titleListSection.titleList.titles.isEmpty {
            sectionTypes.append(.titleList)
        }
        if let bannerSection = homeSection.bannerSection, !bannerSection.banners.isEmpty {
            sectionTypes.append(.banner)
        }
        self.updateSectionTypes = sectionTypes
    }
}
