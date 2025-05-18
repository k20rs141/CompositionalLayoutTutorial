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

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .clear
        addSubview(bannerImage)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bannerImage.pin.top().horizontally().aspectRatio(380/105)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return  .init(width: size.width, height: bannerImage.frame.maxY)
    }

    // MARK: Internal

    func configure(banner: Banner) {
        bannerImage.loadImage(with: banner.imageURL)
    }

    // MARK: Private

    private let bannerImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}

