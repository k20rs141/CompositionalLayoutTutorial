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

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .clear

        addSubview(backgroundImage)
        backgroundImage.addSubview(backgroudGradientView)
        backgroundImage.addSubview(updateLabel)
        backgroundImage.addSubview(bannerContainer)
        bannerContainer.addSubview(thumbnail)
        bannerContainer.addSubview(upBadge)
        bannerContainer.addSubview(newBadge)
        bannerContainer.addSubview(ourPicksBadge)
        bannerContainer.addSubview(thumbnailGradientView)
        bannerContainer.addSubview(titleName)
        bannerContainer.addSubview(chapterLabel)
        bannerContainer.addSubview(views)
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

    func configure(banner: MVBanner) {
        backgroundImage.loadImage(with: banner.imageURL)
        let titleGroups = banner.titleGroups

        if !titleGroups.titles.isEmpty {
            guard let title = titleGroups.titles.first else { return }

            thumbnail.loadImage(with: title.landscapeImageURL)
            let timeString = titleGroups.chapterStartTime
            updateLabel.text = "Every updates are AM \(timeString)."
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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let backgroudGradientView: GradientView = {
        let view: GradientView = .init()
        view.startColor = UIColor(hex: "1E1E1E", alpha: 1.0)
        view.endColor = UIColor(hex: "1E1E1E", alpha: 0.7)
        return view
    }()

    private let bannerContainer: UIView = {
        let view: UIView = .init()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    private let updateLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.text = "Every updates are AM 11:00."
        label.textColor = .white
        label.backgroundColor = .white
        label.layer.opacity = 0.25
        return label
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
        view.endColor = UIColor(hex: "000000", alpha: 0.8)
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

    private let chapterLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .white
        label.layer.opacity = 0.2
        label.layer.cornerRadius = 4
        return label
    }()

    private let views: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(hex: "6E6F75")
        return label
    }()

    private func configureLayout() {
        // 背景画像を横幅いっぱいに表示し、はみ出た部分を切り取る
        backgroundImage.pin.all()

        backgroudGradientView.pin.all()
        updateLabel.pin.top().horizontally().height(27)
        bannerContainer.pin.below(of: updateLabel, aligned: .center).all(16)
        thumbnail.pin.horizontally().top().aspectRatio(2/1)
        upBadge.pin.topLeft(8).height(8.5%).aspectRatio(3/2)
        newBadge.pin.after(of: upBadge, aligned: .bottom).height(8.5%).aspectRatio(3/2).marginLeft(4)
        ourPicksBadge.pin.top().right(8).width(100).height(40)
        thumbnailGradientView.pin.horizontally().bottom().height(80)
        titleName.pin.bottom(16).left(16).height(16).sizeToFit(.width)
        chapterLabel.pin.after(of: titleName, aligned: .bottom).height(16).marginLeft(8).sizeToFit(.width)
        views.pin.after(of: chapterLabel, aligned: .bottom).right(16).height(16).marginLeft(8).sizeToFit(.width)
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
