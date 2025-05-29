//
//  MainTabBarController.swift
//  CompositionalLayoutTutorial
//
//  Created by k-yamada on 2025/04/23.
//

import UIKit

public enum TabBarItem: Int, CaseIterable {
    case update
    case hot
    case browse
    case create
    case profile

    public var title: String {
        switch self {
        case .update:
            return "UPDATE"
        case .hot:
            return "HOT"
        case .browse:
            return "BROWSE"
        case .create:
            return "CREATE"
        case .profile:
            return "PROFILE"
        }
    }

    public var iconImage: UIImage? {
        switch self {
        case .update:
            return UIImage(systemName: "house.fill")
        case .hot:
            return UIImage(systemName: "person.fill")
        case .browse:
            return UIImage(systemName: "magnifyingglass.circle.fill")
        case .create:
            return UIImage(systemName: "plus.circle.fill")
        case .profile:
            return UIImage(systemName: "person.fill")
        }
    }

    @MainActor
    var viewController: UIViewController {
        switch self {
        case .update:
            return UpdateV2ViewController()
        case .hot:
            return UpdateViewController()
        case .browse, .create, .profile:
            return UIViewController()
        }
    }
}

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTab()
    }

    private func setupTab() {
        viewControllers = TabBarItem.allCases.map { item in
            let viewController = item.viewController
            viewController.tabBarItem = UITabBarItem(
                title: item.title,
                image: item.iconImage,
                tag: item.rawValue
            )
            let navigationController = UINavigationController(rootViewController: viewController)
            return navigationController
        }

        configureTabBarAppearance()
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 背景色と影の設定
        appearance.backgroundColor = .systemGray5
        appearance.shadowColor = .systemGray5

        // タブバーの見た目を統一
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false // 透明度をオフにする

        // iOS18.0以上のTabBarの仕様変更を非適用
        if #available(iOS 18.0, *) {
            traitOverrides.horizontalSizeClass = .compact
        }
    }
}

#Preview {
    MainTabBarController()
}
