//
//  PRBanner.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/15.
//

import PinLayout
import UIKit

final class PRBannerCell: UICollectionViewCell {
    static let reuseIdentifier = "PRBannerCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .clear
        addSubview(thumbnail)
        thumbnail.addSubview(prBadge)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = thumbnail.frame.maxY + 16
        return CGSize(width: size.width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: Internal

    func configure(banner: Banner) {
        thumbnail.loadImage(with: banner.imageURL)
    }

    // MARK: Private

    private let thumbnail: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let prBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .prBadge)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private func configureLayout() {
        thumbnail.pin.top(16).horizontally(16).aspectRatio(382/215)
        prBadge.pin.topRight(8).height(7.5%).aspectRatio(3/2)
    }
}
