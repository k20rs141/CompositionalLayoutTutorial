//
//  PreviewCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

final class PreviewSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PreviewSectionCell"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(segmentControlView)
        contentView.addSubview(segmentControlBorderView)
        segmentControlBorderView.addSubview(selectedSegmentBorderView)
        contentView.addSubview(thumbnailCollectionView)
        contentView.addSubview(pageCollectionView)
        contentView.addSubview(infoContainerView)
        infoContainerView.addSubview(favoriteImageView)
        infoContainerView.addSubview(titleLabel)
        infoContainerView.addSubview(authorLabel)
        infoContainerView.addSubview(chevronImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapInfoContainer))
        infoContainerView.addGestureRecognizer(tapGesture)
        infoContainerView.isUserInteractionEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: - Internal

    func configure(previewTabs: [PreviewTab], onInfoTapped: (() -> Void)? = nil) {
        self.previewTabs = previewTabs
        self.selectedTabIndex = 0
        self.onInfoTapped = onInfoTapped
        
        setupSegmentTabs()
        thumbnailCollectionView.reloadData()
        updateSelectedContent()
    }

    // MARK: - Private

    private let segmentControlView: UIView = {
        let view = UIView()
        return view
    }()

    private let segmentControlBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "353535")
        return view
    }()

    private let selectedSegmentBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var thumbnailCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createThumbnailLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PreviewThumbnailCell.self, forCellWithReuseIdentifier: PreviewThumbnailCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var pageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createPageLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.semanticContentAttribute = .forceRightToLeft
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.register(ChapterPageImageCell.self, forCellWithReuseIdentifier: ChapterPageImageCell.reuseIdentifier)
        return collectionView
    }()

    private let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "940008")
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = UIColor(hex: "BEBEBE")
        label.numberOfLines = 1
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let thumbnailHeight: CGFloat = 106
    private let infoHeight: CGFloat = 64
    private let segmentHeight: CGFloat = 40
    private var previewTabs: [PreviewTab] = []
    private var selectedTabIndex: Int = 0
    private var selectedContentIndex: Int = 0
    private var onSelect: ((Int) -> Void)?
    private var onInfoTapped: (() -> Void)?
    private var tabViews: [UIButton] = []
    private var selectedTabMinX: CGFloat = 0

    private func configureLayout() {
        let shouldShowSegments = previewTabs.count > 1
        let segmentTopOffset: CGFloat = shouldShowSegments ? segmentHeight + 8 : 0
        
        if shouldShowSegments {
            segmentControlView.pin.top().horizontally(16).height(segmentHeight)
            segmentControlBorderView.pin.below(of: segmentControlView).horizontally().height(1)
            
            let tabWidth = segmentControlView.bounds.width / CGFloat(previewTabs.count)
            selectedSegmentBorderView.pin.top().height(2).width(tabWidth)
            updateSelectedTabMinX(animated: false)
            
            configureTabButtonsLayout()
            
            thumbnailCollectionView.pin.below(of: segmentControlBorderView).marginTop(8).horizontally().height(thumbnailHeight)
        } else {
            segmentControlView.pin.top().horizontally().height(0)
            segmentControlBorderView.pin.top().horizontally().height(0)
            selectedSegmentBorderView.pin.top().horizontally().height(0)
            
            thumbnailCollectionView.pin.top().horizontally().height(thumbnailHeight)
        }
        
        infoContainerView.pin.bottom().horizontally(16).height(infoHeight)
        pageCollectionView.pin.below(of: thumbnailCollectionView).above(of: infoContainerView).horizontally().marginBottom(16)

        // 作品情報のレイアウト
        chevronImageView.pin.size(16).vCenter().right(10)
        favoriteImageView.pin.left(8).vCenter().width(32).aspectRatio(.portraitThumbnailRatio)
        titleLabel.pin.right(of: favoriteImageView).top(14).before(of: chevronImageView).height(20).marginLeft(10).marginRight(10).sizeToFit(.heightFlexible)
        authorLabel.pin.below(of: titleLabel, aligned: .left).before(of: chevronImageView).height(12).marginTop(4).marginRight(10).sizeToFit(.heightFlexible)
    }

    private func setupSegmentTabs() {
        // 既存のタブボタンを削除
        tabViews.forEach { $0.removeFromSuperview() }
        tabViews.removeAll()
        
        guard previewTabs.count > 1 else { return }
        
        for (index, tab) in previewTabs.enumerated() {
            let tabButton = UIButton(type: .system)
            tabButton.tag = index
            tabButton.setTitle(tab.tabType.rawValue, for: .normal)
            tabButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            tabButton.addTarget(self, action: #selector(didTapTabButton), for: .touchUpInside)
            segmentControlView.addSubview(tabButton)
            tabViews.append(tabButton)
        }
        updateSelectedTabAppearance()
    }

    private func configureTabButtonsLayout() {
        guard !tabViews.isEmpty else { return }
        let tabWidth = segmentControlView.bounds.width / CGFloat(tabViews.count)
        var currentX: CGFloat = 0
        for tabView in tabViews {
            tabView.pin.left(currentX).top().bottom().width(tabWidth)
            currentX += tabWidth
        }
    }

    private func updateSelectedTabAppearance() {
        for (index, button) in tabViews.enumerated() {
            let isSelected = (index == selectedTabIndex)
            button.setTitleColor(isSelected ? .white : UIColor(hex: "6E6F75"), for: .normal)
        }
    }

    private func updateSelectedTabMinX(animated: Bool) {
        guard !tabViews.isEmpty, segmentControlView.bounds.width > 0 else { return }
        let tabWidth = segmentControlView.bounds.width / CGFloat(tabViews.count)
        guard tabWidth > 0 else { return }
        selectedTabMinX = tabWidth * CGFloat(selectedTabIndex)
        
        let updateAction = { [weak self] in
            guard let self = self else { return }
            self.selectedSegmentBorderView.frame.origin.x = self.selectedTabMinX
            self.selectedSegmentBorderView.frame.size.width = tabWidth
        }

        if animated {
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut, animations: updateAction, completion: nil)
        } else {
            updateAction()
        }
    }

    @objc private func didTapTabButton(sender: UIButton) {
        if selectedTabIndex != sender.tag {
            selectedTabIndex = sender.tag
            selectedContentIndex = 0
            updateSelectedTabAppearance()
            updateSelectedTabMinX(animated: true)
            thumbnailCollectionView.reloadData()
            updateSelectedContent()
        }
    }
    
    private func createThumbnailLayout() -> UICollectionViewLayout {
        let thumbnailHeight: CGFloat = 90
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(60),
            heightDimension: .absolute(thumbnailHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createPageLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ -> NSCollectionLayoutSection? in
            guard let self = self,
                  selectedTabIndex < previewTabs.count,
                  selectedContentIndex < previewTabs[selectedTabIndex].chapterPagesList.chapterPages.count else { return nil }

            let selectedChapterPages = previewTabs[selectedTabIndex].chapterPagesList.chapterPages[selectedContentIndex]

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalHeight(1 / CGFloat.previewPageRatio),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = selectedChapterPages.pages.count > 1 ? .groupPaging : .groupPagingCentered
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }
        return layout
    }

    private func updateSelectedContent() {
        guard selectedTabIndex < previewTabs.count,
              selectedContentIndex < previewTabs[selectedTabIndex].chapterPagesList.chapterPages.count else { return }

        let selectedChapterPages = previewTabs[selectedTabIndex].chapterPagesList.chapterPages[selectedContentIndex]

        titleLabel.text = selectedChapterPages.name
        authorLabel.text = selectedChapterPages.author
        favoriteImageView.loadImage(with: selectedChapterPages.favoriteImageURL)

        pageCollectionView.setCollectionViewLayout(createPageLayout(), animated: false)
        pageCollectionView.reloadData()

        setNeedsLayout()
    }

    @objc private func didTapInfoContainer() {
        onInfoTapped?()
        print("infoTapped")
    }
}

// MARK: UICollectionViewDataSource

extension PreviewSectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !previewTabs.isEmpty else { return 0 }

        if collectionView == thumbnailCollectionView {
            return previewTabs.count
        } else if collectionView == pageCollectionView {
            guard selectedTabIndex < previewTabs.count else { return 0 }
            return previewTabs[selectedTabIndex].chapterPagesList.chapterPages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let previewTabs = !previewTabs.isEmpty else { return UICollectionViewCell() }
        
        if collectionView == thumbnailCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PreviewThumbnailCell.reuseIdentifier,
                for: indexPath
            ) as? PreviewThumbnailCell else {
                return UICollectionViewCell()
            }
            let tab = previewTabs[indexPath.row]
            let isSelected = indexPath.row == selectedTabIndex
            cell.configure(tab: tab, isSelected: isSelected)
            return cell
        } else if collectionView == pageCollectionView {
            guard selectedTabIndex < previewTabs.count,
                  indexPath.row < previewTabs[selectedTabIndex].chapterPagesList.chapterPages.count,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ChapterPageImageCell.reuseIdentifier,
                    for: indexPath
                  ) as? ChapterPageImageCell else {
                return UICollectionViewCell()
            }
            let url = previewTabs[selectedTabIndex].chapterPagesList.chapterPages[selectedContentIndex].pages[indexPath.row].mangaPage.imageURL
            cell.configure(url: url)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: UICollectionViewDelegate

extension PreviewSectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == thumbnailCollectionView {
            // サムネイルがタップされた場合
            let previousIndex = selectedTabIndex
            selectedTabIndex = indexPath.row

            if previousIndex != selectedTabIndex {
                // 選択状態が変わった場合のみ更新
                updateSelectedContent()

                // サムネイルリストの表示を更新
                thumbnailCollectionView.reloadItems(at: [IndexPath(row: previousIndex, section: 0), indexPath])
            }
        } else if collectionView == pageCollectionView {
            onSelect?(indexPath.row)
        }
    }
}
