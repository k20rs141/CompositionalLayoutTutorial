//
//  CarouselBannerCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/15.
//

import PinLayout
import UIKit

final class CarouselBannerCell: UICollectionViewCell {
    static let reuseIdentifier = "CarouselBannerCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .clear
        addSubview(thumbnail)
        thumbnail.addSubview(prBadge)
        thumbnail.addSubview(countLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = thumbnail.frame.maxY
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

    func setBannerPageIndicator(current: Int, total: Int) {
        let fullText = "\(current)/\(total)"
        let attributedString = NSMutableAttributedString(string: fullText)

        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.white,
            range: NSRange(location: 0, length: "\(current)".count)
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor(hex: "999999"),
            range: NSRange(location: "\(current)".count, length: fullText.count - "\(current)".count)
        )
        countLabel.attributedText = attributedString
    }

    // MARK: Private

    private let thumbnail: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()

    private let prBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .prBadge)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.opacity = 0.7
        label.backgroundColor = UIColor(hex: "000000", alpha: 0.7)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    private func configureLayout() {
        thumbnail.pin.top().horizontally(16).aspectRatio(382/143)
        prBadge.pin.topRight(8).height(7.5%).aspectRatio(3/2)
        countLabel.pin.bottomRight(6).width(43).height(20)
    }
}
