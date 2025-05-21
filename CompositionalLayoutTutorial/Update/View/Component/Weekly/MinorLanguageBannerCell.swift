//
//  MinorLanguageBannerCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/15.
//

import PinLayout
import UIKit

final class MinorLanguageBannerCell: UICollectionViewCell {
    static let reuseIdentifier = "MinorLanguageBannerCell"
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        layer.cornerRadius = 16
        backgroundColor = UIColor(hex: "0C0C0C")
        addSubview(backgroundImage)
        addSubview(titleName)
        addSubview(closeButton)
        addSubview(thumbnailsContainer)
        addSubview(addButton)
        addSubview(popupImage)
        popupImage.addSubview(popupLabel)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        self.frame = layoutAttributes.bounds
        setNeedsLayout()
        layoutIfNeeded()

        let calculatedHeight = addButton.frame.maxY + 28
        var newFrame = layoutAttributes.frame
        newFrame.size.height = calculatedHeight
        layoutAttributes.frame = newFrame
        
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }
    
    // MARK: Internal
    
    func configure(titles: [Title]) {
        // 既存のサムネイルをクリア
        thumbnailsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        self.titleCount = titles.count
        // サムネイルを追加
        for (index, title) in titles.enumerated() {
            let imageView: UIImageView = {
                let imageView: UIImageView = .init()
                imageView.contentMode = .scaleAspectFit
                imageView.tag = index + 100 // タグを設定して後でレイアウトできるようにする
                imageView.layer.cornerRadius = 6
                imageView.clipsToBounds = true
                return imageView
            }()
            imageView.loadImage(with: title.portraitImageURL)

            thumbnailsContainer.addSubview(imageView)
        }
        // レイアウトを更新
        setNeedsLayout()
    }
    
    // MARK: Private
    
    private var titleCount: Int = 0 {
        didSet {
            popupLabel.text = "There are \(titleCount) titles available"
        }
    }
    
    private let thumbnailsContainer: UIView = {
        let view = UIView()
        //        view.backgroundColor = .clear
        view.backgroundColor = .yellow.withAlphaComponent(0.3)
        return view
    }()

    private let backgroundImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(resource: .minorLanguageBackground)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleName: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "You can read MANGA more\nwith English titles!"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button: UIButton = .init()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        return button
    }()

    private lazy var addButton: UIButton = {
        let button: UIButton = .init()
        button.setTitle("Add English titles", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = UIColor(hex: "F04438")
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        return button
    }()
    
    private let popupImage: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.image = UIImage(resource: .callout)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let popupLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private func configureLayout() {
        backgroundImage.pin.top().horizontally().aspectRatio(16/9)
        titleName.pin.top(16).hCenter().height(44).sizeToFit(.height)
        closeButton.pin.topRight(10).size(24)
        
        // 3列グリッドで各サムネイルを配置
        let columnCount: Int = 3
        let itemSpacing: CGFloat = 8
        let maxTitleCount: Int = 6
        let itemWidth = (thumbnailsContainer.frame.width - (CGFloat(columnCount - 1) * itemSpacing)) / CGFloat(columnCount)
        let aspectRatio: CGFloat = 3/2
        let itemHeight = itemWidth * aspectRatio
        
        let row: CGFloat = titleCount > columnCount ? 2 : 1
        let thumbnailHeight: CGFloat = row == 1 ? itemHeight : itemHeight * row + itemSpacing

        // サムネイルコンテナの配置
        thumbnailsContainer.pin.below(of: titleName).marginTop(16).horizontally(16).height(thumbnailHeight)

        for item in 0 ..< titleCount {
            if item < maxTitleCount {
                guard let thumbnail = thumbnailsContainer.viewWithTag(item + 100) else { continue }

                let row = item / columnCount
                let column = item % columnCount
                let x = CGFloat(column) * (itemWidth + itemSpacing)

                if row == 0 {
                    // 1 行目 → 上端に揃える
                    thumbnail.pin.top(0).left(x).width(itemWidth).height(itemHeight)
                } else {
                    // 2 行目以降 → 同列の 1 行目サムネイルの下に配置
                    if let upper = thumbnailsContainer.viewWithTag(item - columnCount + 100) {
                        thumbnail.pin.top(to: upper.edge.bottom).marginTop(itemSpacing).left(x).width(itemWidth).height(itemHeight)
                    }
                }
            }
        }
        
        // 下部ボタンとポップアップの配置
        addButton.pin.below(of: thumbnailsContainer).marginTop(-8).horizontally(46).height(48)
        popupImage.pin.above(of: addButton, aligned: .center).width(184).marginBottom(-8).aspectRatio(23/4)
        popupLabel.pin.vertically().hCenter().sizeToFit(.height)
    }
    
    @objc
    private func didTapCloseButton() {
        print("Close button tapped")
    }
    
    @objc
    private func didTapAddButton() {
        
    }
}

#Preview {
    let cell = MinorLanguageBannerCell()
    let titles = Array(0..<3).map { index in
        Title(
            id: "title_\(index)",
            name: "マンガタイトル \(index + 1)",
            author: "作者名 \(index + 1)",
            portraitImageURL: URL(string: "https://placehold.jp/3d4070/ffffff/300x450.png")!,
            landscapeImageURL: URL(string: "https://placehold.jp/3d4070/ffffff/450x300.png")!,
            viewCount: Int.random(in: 10000...5000000),
            languages: [.english, .spanish, .french].prefix(Int.random(in: 1...3)).map { $0 },
            badgeType: index % 5 == 0 ? .up : (index % 5 == 1 ? .new : .none)
        )
    }
    cell.configure(titles: titles)
    return cell
}
