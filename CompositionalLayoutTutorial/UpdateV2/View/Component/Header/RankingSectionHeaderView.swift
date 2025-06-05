import UIKit
import PinLayout

final class RankingSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "RankingSectionHeaderView"
    static let elementKind = "ranking-header-element-kind"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "1F1F1F")
        addSubview(titleLabel)
        addSubview(seeMoreButton)
        addSubview(segmentControlView)
        addSubview(segmentControlBorderView)
        segmentControlBorderView.addSubview(selectedSegmentBorderView)

        seeMoreButton.addTarget(self, action: #selector(didTapSeeMore), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: - Internal

    var onTabSelected: ((Int) -> Void)?

    func configure(title: String, tabs: [RankingTab], initialTabIndex: Int = 0, seeMoreAction: (() -> Void)?, onTabSelected: ((Int) -> Void)?) {
        titleLabel.text = title
        self.rankingTabsData = tabs
        self.seeMoreAction = seeMoreAction
        self.onTabSelected = onTabSelected
        
        setTabViews(segmentNames: tabs.map { $0.tabType.displayName })
        
        if tabs.indices.contains(initialTabIndex) {
            selectedTabIndex = initialTabIndex
        } else {
            selectedTabIndex = 0
        }
        updateSelectedTabAppearance()
        updateSelectedTabMinX(animated: false)
        
        titleLabel.sizeToFit()
        setNeedsLayout()
    }

    func selectTab(at index: Int, animated: Bool) {
        guard tabViews.indices.contains(index), selectedTabIndex != index else { return }
        let oldValue = selectedTabIndex
        selectedTabIndex = index
        if oldValue != selectedTabIndex {
            updateSelectedTabAppearance()
            updateSelectedTabMinX(animated: animated)
        }
    }

    // MARK: - Private

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let seeMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.imageView?.tintColor = .white
        // アイコンを右側に表示
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return button
    }()

    private let segmentControlView: UIView = {
        let view = UIView()
        return view
    }()

    private let segmentControlBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "353535")
        return view
    }()

    private let selectedSegmentBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private var tabViews: [UIButton] = []
    private var rankingTabsData: [RankingTab] = []

    private var selectedTabIndex: Int = 0 {
        didSet {
            if oldValue != selectedTabIndex {
                updateSelectedTabAppearance()
                updateSelectedTabMinX(animated: true)
            }
        }
    }
    private var selectedTabMinX: CGFloat = 0
    private var seeMoreAction: (() -> Void)?

    private func configureLayout() {
        seeMoreButton.pin.top(24).bottom(12).right(16).width(83).height(16)
        titleLabel.pin.before(of: seeMoreButton, aligned: .center).left(16).height(20).sizeToFit(.heightFlexible)
        segmentControlView.pin.below(of: titleLabel).horizontally(16).height(40)
        segmentControlBorderView.pin.below(of: segmentControlView).horizontally().height(1)

        let tabWidth = tabViews.isEmpty ? bounds.width / 3 : segmentControlView.bounds.width / CGFloat(tabViews.count)
        selectedSegmentBorderView.pin.top().height(2).width(tabWidth)
        updateSelectedTabMinX(animated: false)

        configureTabButtonsLayout()
    }

    private func setTabViews(segmentNames: [String]) {
        tabViews.forEach { $0.removeFromSuperview() }
        tabViews.removeAll()

        guard !segmentNames.isEmpty else { return }

        for (index, segmentName) in segmentNames.enumerated() {
            let tabButton = UIButton(type: .system)
            tabButton.tag = index
            tabButton.setTitle(segmentName, for: .normal)
            tabButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            tabButton.addTarget(self, action: #selector(didTapTabButton), for: .touchUpInside)
            segmentControlView.addSubview(tabButton)
            tabViews.append(tabButton)
        }
        updateSelectedTabAppearance()
    }

    private func configureTabButtonsLayout() {
        guard !tabViews.isEmpty else { return }
        let tabWidth = segmentControlView.bounds.width / CGFloat(tabViews.count)
        var currentX: CGFloat = 0
        for tabView in tabViews {
            tabView.pin.left(currentX).top().bottom().width(tabWidth)
            currentX += tabWidth
        }
    }
    
    private func updateSelectedTabAppearance() {
        for (index, button) in tabViews.enumerated() {
            let isSelected = (index == selectedTabIndex)
            button.setTitleColor(isSelected ? .white : UIColor(hex: "6E6F75"), for: .normal)
        }
    }

    private func updateSelectedTabMinX(animated: Bool) {
        guard !tabViews.isEmpty, segmentControlView.bounds.width > 0, !tabViews.isEmpty else { return }
        let tabWidth = segmentControlView.bounds.width / CGFloat(tabViews.count)
        guard tabWidth > 0 else { return }
        selectedTabMinX = tabWidth * CGFloat(selectedTabIndex) + 16
        
        let updateAction = { [weak self] in
            guard let self = self else { return }
            self.selectedSegmentBorderView.frame.origin.x = self.selectedTabMinX
            self.selectedSegmentBorderView.frame.size.width = tabWidth
        }

        if animated {
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut, animations: updateAction, completion: nil)
        } else {
            updateAction()
        }
    }

    @objc private func didTapTabButton(sender: UIButton) {
        if selectedTabIndex != sender.tag {
            selectedTabIndex = sender.tag
            onTabSelected?(selectedTabIndex)
        }
    }

    @objc private func didTapSeeMore() {
        seeMoreAction?()
    }
}
