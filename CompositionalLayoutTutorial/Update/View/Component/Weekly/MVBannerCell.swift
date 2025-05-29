//
//  MVBannerCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/15.
//

import PinLayout
import UIKit

final class MVBannerCell: UICollectionViewCell {
    static let reuseIdentifier = "MVBannerCell"
    static var height: CGFloat = 0

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .clear
        clipsToBounds = true
        addSubview(backgroundImage)
        backgroundImage.addSubview(backgroudGradientView)
        backgroundImage.addSubview(bannerContainer)
        bannerContainer.addSubview(thumbnail)
        bannerContainer.addSubview(upBadge)
        bannerContainer.addSubview(newBadge)
        bannerContainer.addSubview(ourPicksBadge)
        bannerContainer.addSubview(thumbnailGradientView)
        bannerContainer.addSubview(titleName)
        bannerContainer.addSubview(canvus)
        canvus.addSubview(chapterLabel)
        canvus.addSubview(views)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.frame = layoutAttributes.frame
        setNeedsLayout()
        layoutIfNeeded()

        var newFrame = layoutAttributes.frame
//        newFrame.size.height = thumbnail.frame.maxY + 16
        newFrame.size.height = backgroudGradientView.frame.maxY
        layoutAttributes.frame = newFrame

        return layoutAttributes
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: Internal

    func configure(banner: MVBanner) {
        let titleGroups = banner.titleGroups

        if !titleGroups.titles.isEmpty {
            guard let title = titleGroups.titles.first else { return }

            backgroundImage.loadImage(with: title.portraitImageURL)
            thumbnail.loadImage(with: banner.imageURL)
            upBadge.isHidden = titleGroups.titleUpdateStatus != .up
            newBadge.isHidden = titleGroups.titleUpdateStatus != .new
            ourPicksBadge.isHidden = titleGroups.titleUpdateStatus != .ourPicks
            titleName.text = title.name
            chapterLabel.text = titleGroups.chapterNumber
            views.text = titleGroups.formattedViewCount
        }
    }

    // MARK: Private

    private let backgroundImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let backgroudGradientView: GradientView = {
        let view: GradientView = .init()
        view.startColor = UIColor(hex: "1E1E1E", alpha: 0.7)
        view.endColor = UIColor(hex: "1E1E1E", alpha: 1.0)
        return view
    }()

    private let bannerContainer: UIView = {
        let view: UIView = .init()
        return view
    }()

    private let thumbnail: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private let thumbnailGradientView: GradientView = {
        let view: GradientView = .init()
        view.startColor = UIColor(hex: "000000", alpha: 0.0)
        view.endColor = UIColor(hex: "000000", alpha: 1.0)
        return view
    }()

    private var upBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .upBadge)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var newBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .newBadge)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let ourPicksBadge: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(resource: .ourPicks)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleName: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let canvus: UIView = {
        let view: UIView = .init()
        return view
    }()

    private let chapterLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.2)
        label.padding = UIEdgeInsets(top: 1.5, left: 4, bottom: 1.5, right: 4)
        label.numberOfLines = 1
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private let views: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "6E6F75")
        label.textAlignment = .center
        return label
    }()

    private func configureLayout() {
        let cellHeight: CGFloat = thumbnail.frame.maxY + 16
        // 背景画像を横幅いっぱいに表示し、はみ出た部分を切り取る
        backgroundImage.pin.top().horizontally().aspectRatio(CGFloat.portraitThumbnailRatio)

        backgroudGradientView.pin.top().horizontally().height(cellHeight)
        bannerContainer.pin.top(20).horizontally(16).height(thumbnail.frame.maxY)
        thumbnail.pin.horizontally().top().aspectRatio(2/1)
        upBadge.pin.topLeft(8).height(8.5%).aspectRatio(3/2)
        newBadge.pin.after(of: upBadge, aligned: .bottom).height(8.5%).aspectRatio(3/2).marginLeft(4)
        ourPicksBadge.pin.top(-12).right(8).width(100).height(40)
        thumbnailGradientView.pin.horizontally().bottom().height(42%)
        titleName.pin.bottom(16).left(16).width(65%).height(16)
        canvus.pin.bottomRight(16).width(88).height(16)
        chapterLabel.pin.left().vertically().width(40).marginRight(8)
        views.pin.right().vertically().width(40)
    }
}

// グラデーションビュー（MVバナー用）
class GradientView: UIView {
    var startColor: UIColor = .clear {
        didSet { updateGradient() }
    }

    var endColor: UIColor = .black {
        didSet { updateGradient() }
    }

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
