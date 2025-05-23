//
//  CGFloat+AspectRatio.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/05/22.
//

import UIKit

extension CGFloat {
    /// 縦長サムネのアスペクト比
    static let portraitThumbnailRatio: CGFloat = 2 / 3
    /// 横長サムネのアスペクト比
    static let landscapeThumbnailRatio: CGFloat = 2 / 1
    /// 広告バナーのアスペクト比
    static let prBannerRatio: CGFloat = 1 / 1.777
    /// トップバナーのアスペクト比
    static let topBannerRatio: CGFloat = 8 / 3
    /// 特集下部バナーのアスペクト比
    static let specialBottomBannerRatio: CGFloat = 1 / 3.178
    /// プレビューページのアスペクト比
    static let previewPageRatio: CGFloat = 1 / 0.68
}