//
//  UILabel+Extension.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/17.
//

import UIKit

final class PaddingLabel: UILabel {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        layer.isOpaque = false
        layer.drawsAsynchronously = true
        clearsContextBeforeDrawing = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    /// padding, default is zero
    var padding: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let currentSize: CGSize = super.sizeThatFits(size)
        let size: CGSize = .init(width: currentSize.width + padding.left + padding.right, height: currentSize.height + padding.top + padding.bottom)
        return size
    }
}
