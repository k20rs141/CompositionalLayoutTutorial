//
//  PreviewCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import UIKit

class PreviewSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "PreviewSectionCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    func configure(content: ChapterPageList) {

    }

    // MARK: - Private

    private func configureLayout() {
    }
}
