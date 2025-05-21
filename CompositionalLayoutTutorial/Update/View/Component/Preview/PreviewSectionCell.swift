//
//  PreviewCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

class PreviewSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PreviewSectionCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(collectionView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: Internal

    func configure(content: ChapterPages) {
        self.chapterPages = content
        collectionView.reloadData()
    }

    // MARK: Private

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.semanticContentAttribute = .forceRightToLeft
        collectionView.backgroundColor = .clear
        collectionView.register(ChapterPageImageCell.self, forCellWithReuseIdentifier: ChapterPageImageCell.reuseIdentifier)
        return collectionView
    }()

    private var onSelect: ((Int) -> Void)?
    private var chapterPages: ChapterPages?

    private func configureLayout() {
        collectionView.pin.all()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, _ -> NSCollectionLayoutSection? in
            guard let self = self, let chapterPages = self.chapterPages else { return nil }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalHeight(0.68),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalHeight(0.68),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = chapterPages.pages.count > 1 ? .groupPaging : .groupPagingCentered
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }
        return layout
    }
}

// MARK: UICollectionViewDataSource

extension PreviewSectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let chapterPages else { return 0 }
        return chapterPages.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let chapterPages = chapterPages, indexPath.row < chapterPages.pages.count else { return UICollectionViewCell() }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChapterPageImageCell.reuseIdentifier,
            for: indexPath
        ) as? ChapterPageImageCell else {
            return UICollectionViewCell()
        }

        let url = chapterPages.pages[indexPath.row].mangaPage.imageURL
        cell.configure(url: url)
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension PreviewSectionCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(indexPath.row)
    }
}
