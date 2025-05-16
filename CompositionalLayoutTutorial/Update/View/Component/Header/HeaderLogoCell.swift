//
//  HeaderCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/22.
//

import PinLayout
import UIKit

final class HeaderLogoCell: UICollectionViewCell {
    static let reuseIdentifier = "HeaderCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(logoImageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        logoImageView.pin.vertically().hCenter().aspectRatio()
    }

    // MARK: Private

    private let logoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "apple.logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}
