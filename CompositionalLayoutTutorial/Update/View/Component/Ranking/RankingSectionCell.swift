//
//  RankingCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

class RankingSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "RankingSectionCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        addSubview(thumbnail)
        addSubview(rankingNumber)
        addSubview(titleName)
        addSubview(author)
        addSubview(languagesContainer)
        addSubview(views)
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

    // MARK: Internal

    func configure(content: Title, index: Int) {
        thumbnail.loadImage(with: content.portraitImageURL)
        rankingNumber.text = "\(index + 1)"
        titleName.text = content.name
        author.text = content.author
        
        // 既存の言語ラベルをクリア
        languagesContainer.subviews.forEach { $0.removeFromSuperview() }

        if !content.languages.isEmpty {
            // 言語ごとにラベルを作成
            for (index, language) in content.languages.enumerated() {
                let label = UILabel()
                label.font = .systemFont(ofSize: 8, weight: .semibold)
                label.text = language.rawValue
                label.textColor = .white
                label.backgroundColor = UIColor(hex: "262626")
                label.textAlignment = .center
                label.layer.cornerRadius = 2
                label.clipsToBounds = true
                languagesContainer.addSubview(label)

                label.tag = index
            }
            languagesContainer.isHidden = false
        } else {
            languagesContainer.isHidden = true
        }
        viewsLabel.text = content.formattedViewCount
    }

    // MARK: Private

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

    private let languagesContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let views: UIView = {
        let view: UIView = .init()
        return view
    }()

    private let viewsIcon: UIImageView = {
        let imageView: UIImageView = .init(image: UIImage(systemName: "flame"))
        imageView.contentMode = .scaleAspectFit
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
        thumbnail.pin.vertically().left().aspectRatio(2/3)
        rankingNumber.pin.after(of: thumbnail, aligned: .bottom).vCenter().width(9).height(22).marginLeft(12)
        titleName.pin.after(of: rankingNumber, aligned: .bottom).top(18.5).height(16).marginLeft(16).sizeToFit(.width)
        author.pin.below(of: titleName, aligned: .left).height(11).marginTop(2).marginBottom(10).sizeToFit(.width)
        languagesContainer.pin.below(of: author, aligned: .left).before(of: views, aligned: .top).height(14).sizeToFit(.width)
        views.pin.after(of: titleName, aligned: .bottom).height(10).width(50)
        viewsIcon.pin.left().height(10).aspectRatio()
        viewsLabel.pin.after(of: viewsIcon, aligned: .bottom).right().vCenter().marginLeft(2)
    }
}
