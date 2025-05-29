import Combine
import PinLayout
import UIKit

final class UpdateV2ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    // MARK: - Lifecycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        loadInitialData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "1F1F1F")
        view.addSubview(scrollView)
        view.addSubview(dayTabBarView)

        scrollView.addSubview(headerLogoView)
        headerLogoView.addSubview(headerLogoImage)
        addChild(pageViewController)
        scrollView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        scrollView.addSubview(collectionView)
        
        setupDataSource()
        setupBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        configureLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureLayout()
        notifyHeightChange()
    }

    // MARK: - Private

    private var weeklyPageViewControllers: [WeeklyPageViewController] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private let viewModel = UpdateV2ViewModel()
    private var currentPageIndex: Int = 0
    private var currentPageViewControllerHeight: CGFloat = 500
    private var currentCollectionViewHeight: CGFloat = 300
    private let columns = 3
    private let rankingColumns = 5
    private var cancellables = Set<AnyCancellable>()
    private var selectedDay: dayOfWeek = .monday
    private var homeSection: HomeSection?
    private var sectionTypes: [Section] = []
    private var rankingHeaderView: RankingSectionHeaderView?

    private let headerLogoView: UIView = {
        let view = UIView()
        return view
    }()

    private let headerLogoImage: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "apple.logo")
        imageView.image = UIImage(resource: .mangaPlusLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var dayTabBarView: WeeklyTabBarView = {
        let view = WeeklyTabBarView()
        return view
    }()

    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        pageViewController.view.backgroundColor = UIColor(hex: "1F1F1F")
        pageViewController.view.backgroundColor = .yellow
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = UIColor(hex: "1F1F1F")
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
//        collectionView.delegate = self
        collectionView.register(RankingSectionCell.self, forCellWithReuseIdentifier: RankingSectionCell.reuseIdentifier)
        collectionView.register(PreviewSectionCell.self, forCellWithReuseIdentifier: PreviewSectionCell.reuseIdentifier)
        collectionView.register(TitleListCell.self, forCellWithReuseIdentifier: TitleListCell.reuseIdentifier)
        collectionView.register(BannerSectionCell.self, forCellWithReuseIdentifier: BannerSectionCell.reuseIdentifier)
        // ヘッダービューの登録
        collectionView.register(RankingSectionHeaderView.self, forSupplementaryViewOfKind: RankingSectionHeaderView.elementKind, withReuseIdentifier: RankingSectionHeaderView.reuseIdentifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: SectionHeaderView.elementKind, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        return collectionView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
//        scrollView.backgroundColor = .orange
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()

    private func configureLayout() {
        let safeAreaTop = view.pin.safeArea.top
        let headerLogoHeight: CGFloat = 48
        let dayTabBarHeight: CGFloat = 64

        // 1. scrollView の contentInset を設定 (dayTabBarView の高さ分)
        scrollView.contentInset = UIEdgeInsets(top: safeAreaTop, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset // スクロールバーの位置も調整

        // 2. scrollViewの内部コンテンツのレイアウト (0,0から開始)
        var contentYOffset: CGFloat = 0
        headerLogoView.pin.top(contentYOffset).horizontally().height(headerLogoHeight)
        headerLogoImage.pin.vertically(12).hCenter().aspectRatio(19/2)
        contentYOffset += headerLogoHeight + dayTabBarHeight // dayTabBarHeight分のスペースを確保しないとpageViewControllerの位置がずれる

        pageViewController.view.pin.top(contentYOffset).horizontally().height(currentPageViewControllerHeight)
        contentYOffset += currentPageViewControllerHeight

        collectionView.pin.top(contentYOffset).horizontally().height(currentCollectionViewHeight)
        contentYOffset += currentCollectionViewHeight

        scrollView.contentSize = CGSize(width: view.bounds.width, height: contentYOffset)
        
        // 3. scrollView は画面全体を占めるようにレイアウト
        scrollView.pin.all()

        // 4. 初期表示時に scrollView の contentOffset を調整
        // これにより、コンテンツが contentInset.top の位置から開始される
        // viewDidLayoutSubviews や viewWillAppear など、レイアウトが確定した後に一度だけ設定するのが良い場合もある
        // ここでは configureLayout の最後に呼ぶことで、関連するレイアウト設定とまとめる
        if scrollView.contentOffset.y != -scrollView.contentInset.top {
             scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        }

        // 5. dayTabBarViewの位置を計算・適用 (contentOffset変更後、または初期位置として)
        updateDayTabBarViewPosition() 
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let self = self,
                  let sectionType = self.dataSource.snapshot().sectionIdentifiers[safe: sectionIndex] else {
                return nil
            }
            let contentSize = layoutEnvironment.container.contentSize
            switch sectionType {
            case .ranking:
                return self.createRankingSection(contentSize: contentSize)
            case .preview:
                return self.createPreviewSection()
            case .titleList:
                return self.createTitleListSection()
            case .banner:
                return self.createBannerSection(contentSize: contentSize)
            }
        }
        return layout
    }

    private func createRankingSection(contentSize: CGSize) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let verticalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500)
        )
        let group: NSCollectionLayoutGroup = {
            if #available(iOS 16.0, *) {
                // repeatingSubitemではなくsubitemsを使用すると特定のOSで列崩れが起きるため、repeatingSubitemを使用
                return NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize, repeatingSubitem: item, count: self.rankingColumns)
            }
            else {
                return NSCollectionLayoutGroup.vertical(layoutSize: verticalGroupSize, subitem: item, count: self.rankingColumns)
            }
        }()
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(96) // ヘッダーの高さ (要調整: TitleName + Tabs)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: RankingSectionHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]

        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, environment) in
            guard let self = self else { return }
            let pageWidth = environment.container.contentSize.width // environmentから取得
            guard pageWidth > 0 else { return } // pageWidthが0の場合は処理をスキップ

            let pageIndex = Int(round(offset.x / pageWidth))

            // print("pageWidth: \(pageWidth), pageIndex: \(pageIndex), offset.x: \(offset.x)")
            if let header = self.rankingHeaderView {
                header.selectTab(at: pageIndex, animated: true)
            }
        }

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

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SectionHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
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

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SectionHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }

    private func createBannerSection(contentSize: CGSize) -> NSCollectionLayoutSection {
        let bannerHeight = contentSize.width * .specialBottomBannerRatio
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(bannerHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
        section.interGroupSpacing = 8
        return section
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            switch item {
            case let .ranking(_, title, index):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RankingSectionCell.reuseIdentifier,
                    for: indexPath
                ) as? RankingSectionCell else {
                    return nil
                }
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
                cell.configure(banner: banner)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard let self = self, let sectionType = self.dataSource.snapshot().sectionIdentifiers[safe: indexPath.section] else {
                return nil
            }

            switch sectionType {
            case .ranking:
                if kind == RankingSectionHeaderView.elementKind {
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: RankingSectionHeaderView.reuseIdentifier,
                        for: indexPath) as? RankingSectionHeaderView else {
                        return nil
                    }
                    self.rankingHeaderView = headerView
                    let rankingTabs = self.homeSection?.rankingSection?.rankingTab ?? []
                    headerView.configure(title: "Ranking", tabs: rankingTabs, seeMoreAction: {
                        print("Ranking See More Tapped!")
                    }, onTabSelected: { [weak self] index in
                        guard let self = self else { return }
                        // CollectionViewをスクロール
                        let sectionContentWidth = self.collectionView.bounds.width
                        let offsetX = sectionContentWidth * CGFloat(index)
                        // Y座標は現在のcollectionViewのcontentOffset.yを維持する
                        let currentYOffset = self.collectionView.contentOffset.y
                        self.collectionView.setContentOffset(CGPoint(x: offsetX, y: currentYOffset), animated: true)
                    })
                    return headerView
                }
            case .preview:
                if kind == SectionHeaderView.elementKind {
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                        for: indexPath) as? SectionHeaderView else {
                        return nil
                    }
                    headerView.configure(sectionType: .preview, title: "Preview")
                    return headerView
                }
            case .titleList:
                if kind == SectionHeaderView.elementKind {
                    guard let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                        for: indexPath) as? SectionHeaderView else {
                        return nil
                    }
                    headerView.configure(
                        sectionType: .titleList,
                        title: self.homeSection?.titleListSection?.titleList.name ?? "Title List"
                    )
                    return headerView
                }
            case .banner: break
            }
            return nil
        }
        let snapshot = dataSource.snapshot()
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func setupBinding() {
        viewModel.$homeSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeSection in
                self?.homeSection = homeSection
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        // 曜日データの変更を監視
        viewModel.$weeklyContents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] weeklyContents in
                self?.setupDayTabBarView(contents: weeklyContents)
                // weeklyPageViewControllersを初期化し直す
                self?.weeklyPageViewControllers = weeklyContents.map { content in
                    let vc = WeeklyPageViewController(weeklyContent: content)
                    vc.onContentHeightChanged = { [weak self] height in
                        self?.currentPageViewControllerHeight = height
                        self?.configureLayout()
                    }
                    return vc
                }
                // 先頭ページをpageViewControllerにセット
                if let firstVC = self?.weeklyPageViewControllers.first {
                    self?.pageViewController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
                    self?.currentPageIndex = 0
                }
            }
            .store(in: &cancellables)
        viewModel.$updateSectionTypes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sectionTypes in
                self?.sectionTypes = sectionTypes
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        // 曜日選択の変更を監視
        viewModel.selectedDayIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                self?.setPage(index: index, animated: true)
            }
            .store(in: &cancellables)
        
        // ViewModelからのランキングタブ選択の変更を監視する場合 (任意)
//        viewModel.$selectedRankingTabIndex
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] index in
//                self?.rankingHeaderView?.selectTab(at: index, animated: true)
//                let sectionContentWidth = self?.collectionView.bounds.width ?? 0
//                let offsetX = sectionContentWidth * CGFloat(index)
//                self?.collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
//            }
//            .store(in: &cancellables)
    }
    // MARK: - データ読み込み
    private func loadInitialData() {
        viewModel.loadHomeSection()
    }

    private func setupDayTabBarView(contents: [WeeklyContent]) {
        // viewModel.weeklyContents から isUpdated と updatedTimeStamp のみ抽出
        let dailyStatusData = contents.map { (isUpdated: $0.isUpdated, updatedTimeStamp: $0.updatedTimeStamp) }
        dayTabBarView.dailyStatus = dailyStatusData
        dayTabBarView.selectedIndex = currentPageIndex
        dayTabBarView.onSelect = { [weak self] index in
            self?.viewModel.selectDay(index: index)
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        guard let homeSection = homeSection, !sectionTypes.isEmpty else { return }
        snapshot.appendSections(sectionTypes)

        for sectionType in sectionTypes {
            switch sectionType {
            case .ranking:
                if let rankingSection = homeSection.rankingSection {
                    var allRankingItems: [Item] = []
                    rankingSection.rankingTab.forEach { tab in
                        // 1つのタブ(ページ)に表示する作品は titleRankingGroup にある titles
                        // titleRankingGroup は配列なので、その中の最初の要素の titles を使う (設計による)
                        // ここでは、RankingTabが複数のTitleRankingGroupを持つことを想定し、
                        // 各TitleRankingGroupが1つのランキング作品リスト(最大5件)を表すと仮定する。
                        // もしRankingTabが直接[Title]を持つなら、tab.titles.enumerated()... のようになる。
                        // 現在のModelではTitleRankingGroupが[Title]を持つので、それを展開する。
                        tab.titleRankingGroup.forEach { group in 
                            let items = group.titles.enumerated().map { (index, title) -> Item in
                                return Item.ranking(group, title, index)
                            }
                            allRankingItems.append(contentsOf: items)
                        }
                    }
                    snapshot.appendItems(allRankingItems, toSection: .ranking)
                }
            case .preview:
                if let previewSection = homeSection.previewSection {
                    snapshot.appendItems([.preview(previewSection.chapterPagesList)], toSection: .preview)
                }
                
            case .titleList:
                if let titleListSection = homeSection.titleListSection {
                    let items = titleListSection.titleList.titles.map { Item.titleList($0) }
                    snapshot.appendItems(items, toSection: .titleList)
                }
                
            case .banner:
                if let bannerSection = homeSection.bannerSection {
                    let items = bannerSection.banners.map { Item.banner($0) }
                    snapshot.appendItems(items, toSection: .banner)
                }
            }
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
        notifyHeightChange(forceLayout: true) // 初期表示時に高さを通知
    }

    private func notifyHeightChange(forceLayout: Bool = false) {
        if forceLayout {
            // CollectionViewの内部レイアウトを強制的に計算させる
            // これにより、collectionViewContentSizeが更新される
            collectionView.layoutIfNeeded()
        }
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // 高さが0より大きく、かつ前回の通知時から変化している場合のみ通知
        if height > 0 {
            currentCollectionViewHeight = height
            configureLayout()
        } else if height == 0 && forceLayout {
            // 強制レイアウトしても高さが0の場合、再度非同期で試みる
            // これでも0の場合は、最小高さを使うか、UIの構造を見直す必要があるかもしれません。
            DispatchQueue.main.async { [weak self] in
                self?.notifyHeightChange(forceLayout: false) // 次のランループで再試行 (forceLayoutはfalseで)
            }
        }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = weeklyPageViewControllers.firstIndex(of: viewController as! WeeklyPageViewController), index > 0 else { return nil }
        return weeklyPageViewControllers[index - 1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = weeklyPageViewControllers.firstIndex(of: viewController as! WeeklyPageViewController), index < weeklyPageViewControllers.count - 1 else { return nil }
        return weeklyPageViewControllers[index + 1]
    }

    // MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentVC = pageViewController.viewControllers?.first as? WeeklyPageViewController, let index = weeklyPageViewControllers.firstIndex(of: currentVC) else { return }
        currentPageIndex = index
        dayTabBarView.selectedIndex = index
        viewModel.selectDay(index: index)
        configureLayout()
    }

    private func setPage(index: Int, animated: Bool) {
        guard index >= 0, index < weeklyPageViewControllers.count else { return }
        let direction: UIPageViewController.NavigationDirection = (index > currentPageIndex) ? .forward : .reverse
        pageViewController.setViewControllers([weeklyPageViewControllers[index]], direction: direction, animated: animated, completion: nil)
        currentPageIndex = index
        dayTabBarView.selectedIndex = index
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            updateDayTabBarViewPosition()
        }
    }

    private func updateDayTabBarViewPosition() {
        let safeAreaTop = view.pin.safeArea.top
        let headerLogoHeight: CGFloat = 48
        let dayTabBarHeight: CGFloat = 64
        
        // contentInset.top を考慮した「実質的な」スクロール量を取得
        let effectiveScrollOffsetY = scrollView.contentOffset.y + scrollView.contentInset.top

        // dayTabBarViewのY座標を計算
        // 通常(スクロール開始時): safeAreaTop + headerLogoHeight - (0 + dayTabBarHeight) = safeAreaTop + headerLogoHeight - dayTabBarHeight
        // これは期待通りではない。dayTabBarViewの初期位置はロゴの直下であるべき。
        // スティッキーヘッダーの基準点は、scrollViewのスクロールとは独立して考える。
        // dayTabBarView は self.view の子なので、その top は self.view の座標系で決まる。

        // headerLogoView が完全に画面外に出るまでのスクロール量: headerLogoHeight
        // dayTabBarView が画面上端に到達するまでのスクロール量: headerLogoHeight
        // scrollView.contentOffset.y が headerLogoHeight を超えたら、dayTabBarView は safeAreaTop に固定される
        
        let currentScrollOffsetY = scrollView.contentOffset.y

        var targetTabBarY: CGFloat
        // ロゴが見えている間 (currentScrollOffsetYが -dayTabBarHeight から headerLogoHeight - dayTabBarHeight の範囲を想定して計算する)
        // もっとシンプルに、scrollView の contentOffset.y を直接使う。
        // contentInset.top の分だけ初期オフセットが深くなるので、それを補正して考える。
        // scrollView がスクロールした量 = scrollView.contentOffset.y - (-scrollView.contentInset.top) = scrollView.contentOffset.y + scrollView.contentInset.top

        let actualScrollDistance = scrollView.contentOffset.y + scrollView.contentInset.top
        
        if actualScrollDistance < headerLogoHeight {
            // ロゴが見えているか、一部隠れている状態
            // dayTabBarView はロゴの下に追従。基準点は safeAreaTop + headerLogoHeight
            // そこからスクロールした分だけ上に移動する
            targetTabBarY = (safeAreaTop + headerLogoHeight) - actualScrollDistance
        } else {
            // ロゴが完全に隠れた状態
            // dayTabBarView は画面上端に固定
            targetTabBarY = safeAreaTop
        }
        // ただし、dayTabBarView が safeAreaTop より上に行くことはない
        targetTabBarY = max(safeAreaTop, targetTabBarY)
        
        dayTabBarView.pin.top(targetTabBarY).horizontally().height(dayTabBarHeight).layout()
    }
}
