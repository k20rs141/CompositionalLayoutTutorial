//
//  RankingCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

final class RankingSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "RankingSectionCell"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(thumbnail)
        contentView.addSubview(rankingNumber)
        contentView.addSubview(titleName)
        contentView.addSubview(author)
        contentView.addSubview(languagesCanvas)
        contentView.addSubview(views)
        views.addSubview(viewsIcon)
        views.addSubview(viewsLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        var newFrame = layoutAttributes.frame
        newFrame.size.height = contentView.bounds.height
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }

    // MARK: - Internal

    func configure(content: Title, index: Int) {
        thumbnail.loadImage(with: content.portraitImageURL)
        rankingNumber.text = "\(index + 1)"
        titleName.text = content.name
        author.text = content.author
        // 言語バッジ
        languagesCanvas.subviews.forEach { $0.removeFromSuperview() }
        if !content.languages.isEmpty {
            var tagX: CGFloat = 0
            var tagY: CGFloat = 0
            var tagHeight: CGFloat = 0
            let _: [UILabel] = content.languages.enumerated().map { tuple -> UILabel in
                let label: UILabel = .init(frame: CGRect(x: tagX, y: tagY, width: 0, height: 14))
                label.attributedText = NSAttributedString(string: tuple.element.rawValue)
                label.textColor = .white
                label.font = .systemFont(ofSize: 8, weight: .semibold)
                label.backgroundColor = UIColor(hex: "444444")
                label.textAlignment = .center
                label.layer.cornerRadius = 3
                label.clipsToBounds = true
                let maxWidth: CGFloat = (self.contentView.frame.width - 24)
                label.sizeToFit()
                if label.frame.width > maxWidth {
                    let size: CGSize = .init(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
                    let fixSize: CGSize = label.sizeThatFits(size)
                    label.frame = CGRect(x: label.frame.minX, y: label.frame.minY, width: fixSize.width, height: fixSize.height)
                }
                tagX += label.frame.size.width + 6
                if label.frame.maxX >= (self.contentView.frame.width - 24) {
                    tagX = 0
                    label.frame.origin.x = tagX
                    tagX += label.frame.size.width + 6
                    tagY = tagHeight + 4
                    label.frame.origin.y = tagY
                }
                tagHeight = label.frame.maxY
                languagesCanvas.addSubview(label)
                return label
            }
            languagesCanvas.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width - 24, height: tagHeight)
            languagesCanvas.isHidden = false
        } else {
            languagesCanvas.isHidden = true
        }
        viewsLabel.text = content.formattedViewCount
    }

    // MARK: - Private

    private let thumbnail: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        return imageView
    }()

    private let rankingNumber: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.layer.opacity = 0.4
        return label
    }()

    private let titleName: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private let author: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 9, weight: .medium)
        label.textColor = UIColor(hex: "BEBEBE")
        label.numberOfLines = 1
        return label
    }()

    private let languagesCanvas: UIView = {
        let view = UIView()
        return view
    }()

    private let views: UIView = {
        let view: UIView = .init()
        return view
    }()

    private let viewsIcon: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(systemName: "flame")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let viewsLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 9, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private func configureLayout() {
        thumbnail.pin.vertically().left(16).aspectRatio(2/3)
        rankingNumber.pin.after(of: thumbnail, aligned: .center).width(15).height(22).marginLeft(12)
        titleName.pin.after(of: rankingNumber).before(of: views).top(18.5).height(16).marginLeft(16).marginRight(8).sizeToFit(.height)
        author.pin.below(of: titleName, aligned: .left).height(11).marginTop(2).marginBottom(10).sizeToFit(.height)
        languagesCanvas.pin.below(of: author, aligned: .left).height(14).marginTop(10).sizeToFit(.height)
        views.pin.top(18.5).right(16).width(50).height(10).marginLeft(4)
        viewsIcon.pin.left().vertically().aspectRatio()
        viewsLabel.pin.after(of: viewsIcon).right().vertically().marginLeft(2)
    }
}
