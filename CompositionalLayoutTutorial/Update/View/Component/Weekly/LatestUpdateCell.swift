//
//  LatestUpdateCell.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/19.
//

import PinLayout
import UIKit

final class LatestUpdateCell: UICollectionViewCell {
    static let reuseIdentifier = "LatestUpdateCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = .white.withAlphaComponent(0.25)
        addSubview(updateLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabel.pin.vertically().hCenter().sizeToFit(.height)
    }

    // MARK: Internal

    func configure(updateTimeStamp: UInt32) {
        updateLabel.text = "Latest Update：Every updates are \(updateTimeStamp)."
    }

    // MARK: Private

    private let updateLabel: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        return label
    }()
}
