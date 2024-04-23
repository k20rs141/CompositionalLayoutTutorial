//
//  UICollectionView.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2024/04/22.
//

import Foundation
import UIKit

extension NSObjectProtocol {
    // クラス名を返す変数"className"を返す
    static var className: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    // 独自に定義したセルのクラス名を返す
    static var identifier: String {
        return className
    }
}

extension UICollectionView {
    func registerCustomCell<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(UINib(nibName: T.identifier, bundle: nil), forCellWithReuseIdentifier: T.identifier)
    }

    func registerCustomReusableHeaderView<T: UICollectionReusableView>(_ viewType: T.Type) {
        register(UINib(nibName: T.identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader ,withReuseIdentifier: T.identifier)
    }

    func registerCustomReusableFooterView<T: UICollectionReusableView>(_ viewType: T.Type) {
        register(UINib(nibName: T.identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter ,withReuseIdentifier: T.identifier)
    }

    func dequeueReusableCustomCell<T: UICollectionViewCell>(with cellType: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }

    func dequeueReusableCustomHeaderView<T: UICollectionReusableView>(with cellType: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }

    func dequeueReusableCustomFooterView<T: UICollectionReusableView>(with cellType: T.Type, indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}
