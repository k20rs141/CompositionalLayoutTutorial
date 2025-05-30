import UIKit

final class WeeklyPageViewController: UIViewController {

    // MARK: - Lifecycle

    init(weeklyContent: WeeklyContent) {
        self.weeklyContent = weeklyContent
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
        applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        configureLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.pin.all()
        // viewDidLayoutSubviewsが呼ばれるたびに高さをチェックし、変更があれば通知
        notifyHeightChange()
    }

    // MARK: - Internal

    /// 高さ変更通知クロージャ
    var onContentHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Private

    private let weeklyContent: WeeklyContent
    private var lastNotifiedHeight: CGFloat = 0
    private var dataSource: UICollectionViewDiffableDataSource<WeeklyContentSection, WeeklySectionItem>!

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView.backgroundColor = .blue
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceVertical = false
        collectionView.register(LatestUpdateCell.self, forCellWithReuseIdentifier: LatestUpdateCell.reuseIdentifier)
        collectionView.register(PRBannerCell.self, forCellWithReuseIdentifier: PRBannerCell.reuseIdentifier)
        collectionView.register(MVBannerCell.self, forCellWithReuseIdentifier: MVBannerCell.reuseIdentifier)
        collectionView.register(TitleListCell.self, forCellWithReuseIdentifier: TitleListCell.reuseIdentifier)
        collectionView.register(CarouselBannerCell.self, forCellWithReuseIdentifier: CarouselBannerCell.reuseIdentifier)
        collectionView.register(MinorLanguageBannerCell.self, forCellWithReuseIdentifier: MinorLanguageBannerCell.reuseIdentifier)
        return collectionView
    }()

    private func configureLayout() {
        collectionView.pin.all()
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        // 高さが0以外かつ前回と異なる場合のみ通知
        if height > 0 {
            lastNotifiedHeight = height
            onContentHeightChanged?(height)
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let self = self, let section = self.dataSource?.snapshot().sectionIdentifiers[sectionIndex] else { return nil }
            let contentSize = layoutEnvironment.container.contentSize
            switch section {
            case .latestUpdate:
                return self.createLatestUpdateSection()
            case .prBanner:
                return self.createPRBannerSection(contentSize: contentSize)
            case .mvBanner:
                return self.createMVBannerSection()
            case .titleGroup:
                return self.createContentGridSection()
            case .carouselBanners:
                return self.createCarouselBannerSection(contentSize: contentSize)
            case .minorLanguageBanner:
                return self.createMinorLanguageBannerSection()
            }
        }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<WeeklyContentSection, WeeklySectionItem>(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }

            switch item {
            case let .latestUpdate(updateTimeStamp):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: LatestUpdateCell.reuseIdentifier,
                    for: indexPath
                ) as? LatestUpdateCell else {
                    return nil
                }
                cell.configure(updateTimeStamp: updateTimeStamp)
                return cell
            case let .prBanner(banner):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PRBannerCell.reuseIdentifier,
                    for: indexPath
                ) as? PRBannerCell else {
                    return nil
                }
                cell.configure(banner: banner)
                return cell
            case let .mvBanner(banner):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MVBannerCell.reuseIdentifier,
                    for: indexPath
                ) as? MVBannerCell else {
                    return nil
                }
                cell.configure(banner: banner)
                return cell
            case let .titleGroup(titleGroup):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TitleListCell.reuseIdentifier,
                    for: indexPath
                ) as? TitleListCell else {
                    return nil
                }
                cell.configure(content: titleGroup)
                return cell
            case let .carouselBanner(banner):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CarouselBannerCell.reuseIdentifier,
                    for: indexPath
                ) as? CarouselBannerCell else {
                    return nil
                }
                cell.configure(banner: banner)

                let totalBanners = dataSource?.snapshot().numberOfItems(inSection: .carouselBanners) ?? 0
                if totalBanners > 0 {
                    cell.setBannerPageIndicator(current: indexPath.item + 1, total: totalBanners)
                }
                return cell
            case let .minorLanguageBanner(titles):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MinorLanguageBannerCell.reuseIdentifier,
                    for: indexPath
                ) as? MinorLanguageBannerCell else {
                    return nil
                }
                guard !titles.titleGroups.titles.isEmpty else { return nil }

                cell.configure(titles: titles.titleGroups.titles)
                return cell
            }
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<WeeklyContentSection, WeeklySectionItem>()
        for item in weeklyContent.contentItems {
            switch item {
            case let .latestUpdate(updateTimeStamp):
                snapshot.appendSections([.latestUpdate])
                snapshot.appendItems([.latestUpdate(updateTimeStamp)], toSection: .latestUpdate)
            case let .prBanner(prBanner):
                snapshot.appendSections([.prBanner])
                snapshot.appendItems([.prBanner(prBanner)], toSection: .prBanner)
            case let .mvBanner(mvBanner):
                snapshot.appendSections([.mvBanner])
                snapshot.appendItems([.mvBanner(mvBanner)], toSection: .mvBanner)
            case let .titleGroup(titleGroup):
                snapshot.appendSections([.titleGroup])
                let titleItems = titleGroup.originalTitleGroup.map { WeeklySectionItem.titleGroup($0) }
                snapshot.appendItems(titleItems, toSection: .titleGroup)
            case let .carouselBanner(carouselBanner):
                if !carouselBanner.banners.isEmpty {
                    snapshot.appendSections([.carouselBanners])
                    let carouselItems = carouselBanner.banners.map { WeeklySectionItem.carouselBanner($0) }
                    snapshot.appendItems(carouselItems, toSection: .carouselBanners)
                }
            case let .minorLanguageBanner(minorLanguageBanner):
                snapshot.appendSections([.minorLanguageBanner])
                snapshot.appendItems([.minorLanguageBanner(minorLanguageBanner)], toSection: .minorLanguageBanner)
            }
        }
        dataSource?.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self else { return }
            self.collectionView.layoutIfNeeded()
            self.notifyHeightChange(forceLayout: true)
        }
    }

    private func createLatestUpdateSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(27)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return section
    }

    private func createPRBannerSection(contentSize: CGSize) -> NSCollectionLayoutSection {
        let prBannerHeight = contentSize.width * .prBannerRatio
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(prBannerHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return section
    }
    
    private func createMVBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(225)
//            heightDimension: .absolute(225)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
    
    private func createContentGridSection() -> NSCollectionLayoutSection {
        let columns: Int = 3
        let groupSpacing: CGFloat = 8
        let horizontalSpacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
            heightDimension: .estimated(180)
//            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
//            heightDimension: .absolute(180)
        )
        let group: NSCollectionLayoutGroup = {
            if #available(iOS 16.0, *) {
                // repeatingSubitemではなくsubitemsを使用すると特定のOSで列崩れが起きるため、repeatingSubitemを使用
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
            }
            else {
                return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            }
        }()
        group.interItemSpacing = .fixed(groupSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = horizontalSpacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: horizontalSpacing,
            bottom: 16,
            trailing: horizontalSpacing
        )
        return section
    }
    
    private func createCarouselBannerSection(contentSize: CGSize) -> NSCollectionLayoutSection {
        let horizontalSpacing: CGFloat = 16
        let groupSpacing: CGFloat = 8
        let width = view.frame.width - horizontalSpacing * 2

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(width),
            heightDimension: .absolute(width / .topBannerRatio)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = groupSpacing
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: horizontalSpacing, bottom: 16, trailing: horizontalSpacing)
        
        return section
    }

    private func createMinorLanguageBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500)
//            heightDimension: .absolute(500)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)
        
        return section
    }

    private func notifyHeightChange(forceLayout: Bool = false) {
        if forceLayout {
            collectionView.layoutIfNeeded()
        }
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        // 高さが0より大きく、かつ前回の通知時から変化している場合のみ通知
        if height > 0 && height != lastNotifiedHeight {
            lastNotifiedHeight = height
            onContentHeightChanged?(height)
        } else if height == 0 && forceLayout {
            // 強制レイアウトしても高さが0の場合、再度非同期で試みる
            DispatchQueue.main.async { [weak self] in
                self?.notifyHeightChange(forceLayout: false)
            }
        }
    }
}
