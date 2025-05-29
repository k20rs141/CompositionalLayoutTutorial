//
//  BannerCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

final class BannerSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "BannerSectionCell"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bannerImage)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        bannerImage.pin.top().horizontally().aspectRatio(1 / CGFloat.specialBottomBannerRatio)
        bannerImage.pin.all()
    }

    // MARK: - Internal

    func configure(banner: Banner) {
        bannerImage.loadImage(with: banner.imageURL)
    }

    // MARK: - Private

    private let bannerImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
}

