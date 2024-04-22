import UIKit

enum MainSection: Int, CaseIterable {
    case banners
    case interviews
    case recentKeywords
    case newArrivalArticles
    case regularArticles
}

class ViewController: UIViewController {
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
    }
    // UICollectionViewを差分更新するため
    private  var snapshot: NSDiffableDataSourceSnapshot<MainSection, AnyHashable>!
    // UICollectionViewを組み立てるためのDataSource
    private var dataSource: UICollectionViewDiffableDataSource<MainSection, AnyHashable>! = nil

    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            switch sectionIndex {

            case MainSection.banners.rawValue:
                return self?.createBannersLayout()

            case MainSection.interviews.rawValue:
                return self?.createInterviewsLayout()

            case MainSection.recentKeywords.rawValue:
                return self?.createRecentKeyordsLayout()

            case MainSection.newArrivalArticles.rawValue:
                return self?.createNewArrivalArticlesLayout()

            case MainSection.regularArticles.rawValue:
                return self?.createRegularArticlesLayout()

            default:
                fatalError()
            }
        }
        return layout
    }()

    private func setCollectionViewCompositionalLayout() {
        snapshot = NSDiffableDataSourceSnapshot<MainSection, AnyHashable>()
        snapshot.appendSections(MainSection.allCases)
        for mainSection in MainSection.allCases {
            snapshot.appendItems([], toSection: mainSection)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // １番上に表示されるバナー
    private func createBannersLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero

        let groupHeight = UIScreen.main.bounds.width * (3 / 8)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = .zero

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }

    // フィード表示
    private func createInterviewsLayout() -> NSCollectionLayoutSection {
        let estimatedHeight = (scene?.windows.first?.bounds.height ?? 0) + 200
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(estimatedHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .zero
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        return section
    }

    // 最近のキーワード表示
    private func createRecentKeyordsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)

        // MEMO: 1列に表示するカラム数を1として設定し、itemのサイズがgroupのサイズで決定する形にしている
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        group.contentInsets = .zero

        let section = NSCollectionLayoutSection(group: group)
        // HeaderとFooterのレイアウトを決定する
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(65.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(28.0))
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [header, footer]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 16, trailing: 6)
        // MEMO: スクロール終了時の速度が0になった位置で止まる
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        return section
    }

    // 新着メニュー表示
    private func createNewArrivalArticlesLayout() -> NSCollectionLayoutSection {
        // MEMO: 全体幅2/3の正方形を作るために左側の幅を.fractionalWidth(0.67)に決める
        let twoThirdItemSet = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.67), heightDimension: .fractionalHeight(1.0)))
        twoThirdItemSet.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        // MEMO: 右側に全体幅1/3の正方形を2つ作るために高さを.fractionalHeight(0.5)に決める
        let oneThirdItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
        oneThirdItem.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        // MEMO: 1列に表示するカラム数を2として設定し、Group内のアイテムの幅を1/3の正方形とするためにGroup内の幅を.fractionalWidth(0.33)に決める
        let oneThirdItemSet = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0)), repeatingSubitem: oneThirdItem, count: 2)
 
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0)), subitems: [twoThirdItemSet, oneThirdItem])
        let section = NSCollectionLayoutSection(group: group)
        // HeaderとFooterのレイアウトを決定する
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)

        return section
    }

    // おすすめ記事一覧表示
    private func createRegularArticlesLayout() -> NSCollectionLayoutSection {
        let width = scene?.windows.first?.bounds.width ?? 0
        let absoluteHeight = (width * 0.5) + 90
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(absoluteHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(absoluteHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]

        return section
    }
}

