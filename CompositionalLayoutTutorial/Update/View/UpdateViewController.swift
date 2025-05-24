import UIKit
import Combine
import PinLayout

final class UpdateViewController: UIViewController {
    
    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        setupDataSource()
        setupBinding()

        loadInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let tabBarHeight: CGFloat = tabBarController?.tabBar.frame.height ?? 0
        view.pin.top(statusBarHeight).bottom(tabBarHeight).horizontally()
        collectionView.pin.all()
    }

    // MARK: - private

    private let viewModel = UpdateViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<UpdateSectionType, UpdateSectionItem>!
    private var cancellables = Set<AnyCancellable>()
    private var selectedDay: dayOfWeek = .monday
    private let columns = 3
    
    // 各セクションの状態を管理
    private var homeSection: HomeSection?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(hex: "1F1F1F")
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(HeaderLogoCell.self, forCellWithReuseIdentifier: HeaderLogoCell.reuseIdentifier)
        collectionView.register(WeeklySectionCell.self, forCellWithReuseIdentifier: WeeklySectionCell.reuseIdentifier)
        collectionView.register(RankingSectionCell.self, forCellWithReuseIdentifier: RankingSectionCell.reuseIdentifier)
        collectionView.register(PreviewSectionCell.self, forCellWithReuseIdentifier: PreviewSectionCell.reuseIdentifier)
        collectionView.register(TitleListCell.self, forCellWithReuseIdentifier: TitleListCell.reuseIdentifier)
        collectionView.register(BannerSectionCell.self, forCellWithReuseIdentifier: BannerSectionCell.reuseIdentifier)

        collectionView.register(
            DaySelectorHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DaySelectorHeader.reuseIdentifier
        )
        
        return collectionView
    }()

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let self = self,
                  let sectionType = self.dataSource.snapshot().sectionIdentifiers[safe: sectionIndex] else {
                return nil
            }
            let contentSize = layoutEnvironment.container.contentSize
            switch sectionType {
            case .header:
                return self.createHeaderSection()
            case .weekly:
                return self.createWeeklySection(contentSize: contentSize)
            case .ranking:
                return self.createRankingSection()
            case .preview:
                return self.createPreviewSection()
            case .titleList:
                return self.createTitleListSection()
            case .banner:
                return self.createBannerSection()
            }
        }
        return layout
    }

    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(48)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    // 曜日コンテンツセクション + 曜日選択ヘッダー
    private func createWeeklySection(contentSize: CGSize) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1000)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(64)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        sectionHeader.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader]

        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, environment) in
            guard let self = self else { return }
            let pageWidth = contentSize.width
            let pageIndex = Int(round(offset.x / pageWidth))

            if dayOfWeek.allCases.indices.contains(pageIndex) {
                let day = dayOfWeek.allCases[pageIndex]
                if self.selectedDay != day {
                    self.selectedDay = day
                    self.viewModel.selectDay(day)
                    self.updateDaySelectorSelection(day: day)
                }
            }
        }
        return section
    }

    private func createRankingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }

    private func createPreviewSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(566)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

        return section
    }
    
    private func createTitleListSection() -> NSCollectionLayoutSection {
        let columns = 3
        let groupSpacing: CGFloat = 16
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / CGFloat(columns)),
            heightDimension: .estimated(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        let group: NSCollectionLayoutGroup = {
            if #available(iOS 16.0, *) {
                // repeatingSubitemではなくsubitemsを使用すると特定のOSで列崩れが起きるため、repeatingSubitemを使用
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: self.columns)
            }
            else {
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: self.columns)
            }
        }()
        group.interItemSpacing = .fixed(groupSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = groupSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: groupSpacing,
            bottom: 0,
            trailing: groupSpacing
        )
        return section
    }

    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(106)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
        section.interGroupSpacing = 8
        return section
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<UpdateSectionType, UpdateSectionItem>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch item {
            case .header:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HeaderLogoCell.reuseIdentifier,
                    for: indexPath
                ) as? HeaderLogoCell
                return cell
                
            case let .weekly(weeklyContent):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: WeeklySectionCell.reuseIdentifier,
                    for: indexPath
                ) as? WeeklySectionCell else {
                    return nil
                }
                cell.configure(weeklyContent: weeklyContent)
                return cell

            case let .ranking(_, title, index):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RankingSectionCell.reuseIdentifier,
                    for: indexPath
                ) as? RankingSectionCell else {
                    return nil
                }
                // 直接タイトルとインデックスを渡す
                cell.configure(content: title, index: index)
                return cell

            case let .preview(chapterPageList):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PreviewSectionCell.reuseIdentifier,
                    for: indexPath
                ) as? PreviewSectionCell else {
                    return nil
                }

                cell.configure(content: chapterPageList.chapterPages.first!)
                return cell

            case let .titleList(originalTitleGroup):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TitleListCell.reuseIdentifier,
                    for: indexPath
                ) as? TitleListCell else {
                    return nil
                }
                cell.configure(content: originalTitleGroup)
                return cell

            case let .banner(banner):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: BannerSectionCell.reuseIdentifier,
                    for: indexPath
                ) as? BannerSectionCell else {
                    return nil
                }
                // 個別のBannerを直接渡す
                cell.configure(banner: banner)
                return cell
            }
        }

        dataSource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self,
                  kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            
            // セクションタイプを取得
            guard let sectionType = UpdateSectionType(rawValue: indexPath.section) else {
                return nil
            }
            
            // セクションタイプに応じたヘッダービューを返す
            switch sectionType {
            case .weekly:
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DaySelectorHeader.reuseIdentifier,
                    for: indexPath
                ) as? DaySelectorHeader
                
                header?.configure(with: dayOfWeek.allCases, selectedDate: self.selectedDay)
                return header
                
            case .ranking, .preview:
                // ランキング、プレビューセクション用の仮のヘッダー
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DaySelectorHeader.reuseIdentifier,
                    for: indexPath
                ) as? DaySelectorHeader
                
                // 空の設定でヘッダーを返す
                header?.configure(with: [], selectedDate: .monday)
                header?.backgroundColor = .lightGray
                return header
                
            default:
                return nil
            }
        }

        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.header])
        snapshot.appendItems([.header], toSection: .header)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // 曜日選択時の処理
    private func daySelected(_ day: dayOfWeek) {
        // 選択中の曜日を更新
        selectedDay = day
        // ViewModelに選択した曜日を通知
        viewModel.selectDay(day)
        // 曜日コンテンツセクションの対応するページにスクロール
        scrollToDay(day)
    }
    
    // MARK: - Combine バインディング
    private func setupBinding() {
        // ホームセクションの更新を監視
        viewModel.homeSectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeSection in
                self?.homeSection = homeSection
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        // セクションタイプの更新を監視
        viewModel.updateSectionTypePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)

        // 選択中の曜日の変更を監視
        viewModel.selectedDayPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] day in
                self?.selectedDay = day
            }
            .store(in: &cancellables)
        
        // ローディング状態の監視
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // ローディングインジケータの表示/非表示
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        // エラーの監視
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - データ読み込み
    private func loadInitialData() {
        // 初期の曜日コンテンツを読み込む
        viewModel.selectDay(selectedDay)
        viewModel.loadHomeSection()
    }
    
    // MARK: - スナップショット更新
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<UpdateSectionType, UpdateSectionItem>()
        
        // ViewModelから現在のセクションタイプを取得
        let sectionTypes = viewModel.updateSectionTypePublisher.value
        
        // セクションの追加
        snapshot.appendSections(sectionTypes)
        
        // セクションごとにアイテムを追加
        for sectionType in sectionTypes {
            switch sectionType {
            case .header:
                snapshot.appendItems([.header], toSection: .header)

            case .weekly:
                if let weeklySection = homeSection?.weeklySection {
                    let items = weeklySection.contents.map { UpdateSectionItem.weekly($0) }
                    snapshot.appendItems(items, toSection: .weekly)
                }

            case .ranking:
                if let rankingSection = homeSection?.rankingSection,
                   let rankingTab = rankingSection.rankingTab.first,
                   !rankingTab.titleRankingGroup.isEmpty {
                    let titleRankingGroup = rankingTab.titleRankingGroup.first!
                    // 各タイトルごとにアイテムを生成する（タイトルとインデックスも含める）
                    let items = titleRankingGroup.titles.enumerated().map { index, title in
                        return UpdateSectionItem.ranking(titleRankingGroup, title, index)
                    }
                    snapshot.appendItems(items, toSection: .ranking)
                }

            case .preview:
                if let previewSection = homeSection?.previewSection {
                    snapshot.appendItems([.preview(previewSection.chapterPagesList)], toSection: .preview)
                }
                
            case .titleList:
                if let titleListSection = homeSection?.titleListSection {
                    let items = titleListSection.titleList.titles.map { UpdateSectionItem.titleList($0) }
                    snapshot.appendItems(items, toSection: .titleList)
                }
                
            case .banner:
                if let bannerSection = homeSection?.bannerSection {
                    let items = bannerSection.banners.map { UpdateSectionItem.banner($0) }
                    snapshot.appendItems(items, toSection: .banner)
                }
            }
        }

        dataSource?.apply(snapshot, animatingDifferences: false)
    }

    // 曜日セレクターの選択状態を更新
    private func updateDaySelectorSelection(day: dayOfWeek) {
        guard let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: UpdateSectionType.weekly.rawValue)
        ) as? DaySelectorHeader else {
            return
        }
    }
    
    // MARK: - ヘルパーメソッド
    
    // ローディング状態の更新
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            // ローディングインジケータの表示
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            activityIndicator.tag = 100
            
            view.addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        } else {
            // ローディングインジケータの非表示
            view.subviews.forEach { subview in
                if subview.tag == 100 {
                    subview.removeFromSuperview()
                }
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "エラー",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension UpdateViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // ここでは曜日選択は処理しない（ヘッダーで処理するため）
    }
    
    // 選択した曜日のページにスクロール
    private func scrollToDay(_ day: dayOfWeek) {
        // 曜日のインデックスを取得
        guard let index = dayOfWeek.allCases.firstIndex(of: day) else { return }
        
        // 曜日コンテンツセクション内の対応するアイテムを選択
        let indexPath = IndexPath(item: index, section: UpdateSectionType.weekly.rawValue)
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
