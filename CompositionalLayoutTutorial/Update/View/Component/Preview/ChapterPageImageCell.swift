//
//  ChapterPageImageCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/16.
//

import PinLayout
import UIKit

final class ChapterPageImageCell: UICollectionViewCell {
    static let reuseIdentifier = "ChapterPageImageCell"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chapterImage)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chapterImage.pin.all()
    }

    // MARK: - Internal

    func configure(url: URL) {
        chapterImage.loadImage(with: url)
    }

    //MARK: - Private

    private let chapterImage: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
}
