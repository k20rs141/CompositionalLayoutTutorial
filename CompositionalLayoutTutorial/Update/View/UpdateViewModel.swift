import Foundation
import Combine

class UpdateViewModel {
    // 出力用のパブリッシャー
    let homeSectionPublisher = PassthroughSubject<HomeSection, Never>()
    let selectedDayPublisher = CurrentValueSubject<dayOfWeek, Never>(.monday)
    let isLoadingPublisher = CurrentValueSubject<Bool, Never>(false)
    let errorPublisher = PassthroughSubject<Error, Never>()
    let updateSectionTypePublisher = CurrentValueSubject<[UpdateSectionType], Never>([])

    private var homeSection: HomeSection?
    private var cancellables = Set<AnyCancellable>()
    
    // viewModelでUpdateSectionTypeを管理
    private var updateSectionType: [UpdateSectionType] = [] {
        didSet {
            updateSectionTypePublisher.send(updateSectionType)
        }
    }

    // 曜日を選択
    func selectDay(_ day: dayOfWeek) {
        selectedDayPublisher.send(day)
    }

    func loadHomeSection() {
        isLoadingPublisher.send(true)

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            let homeSection = self.createMockHomeSection()

            DispatchQueue.main.async {
                self.homeSection = homeSection
                self.updateSectionTypes()
                self.homeSectionPublisher.send(homeSection)
                self.isLoadingPublisher.send(false)
            }
        }
    }
    
    // homeSectionの内容からupdateSectionTypeを更新
    private func updateSectionTypes() {
        guard let homeSection = homeSection else { return }

        var sectionTypes: [UpdateSectionType] = []        
        // 常にヘッダーを追加
        sectionTypes.append(.header)

        if let weeklySection = homeSection.weeklySection, !weeklySection.contents.isEmpty {
            sectionTypes.append(.weekly)
        }
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
        self.updateSectionType = sectionTypes
    }
}
