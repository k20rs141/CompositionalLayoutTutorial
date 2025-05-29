import UIKit
import PinLayout

/// 曜日タブ（横スクロール・スワイプなし、全曜日常時表示、タップで切り替え）
final class WeeklyTabBarView: UIView {

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "1F1F1F")
        addSubview(stackView)
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

    struct DayDisplayInfo {
        let dateText: String
        let dayOfWeekText: String
        let isUpdated: Bool
    }

    var dailyStatus: [(isUpdated: Bool, updatedTimeStamp: UInt32)] = [] {
        didSet {
            updateTabs()
        }
    }

    var selectedIndex: Int = dayOfWeek.allCases.firstIndex(where: { $0.isToday }) ?? 0 {
        didSet(oldValue) {
            if oldValue != selectedIndex {
                updateSelection()
            }
        }
    }

    var onSelect: ((Int) -> Void)?

    // MARK: - Private

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    private var tabButtons: [WeeklyTabButton] = []
    private var currentDisplayInfos: [DayDisplayInfo] = []

    private func configureLayout() {
        stackView.pin.horizontally(8).vertically()
    }

    private func updateTabs() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        currentDisplayInfos.removeAll()

        for (index, status) in dailyStatus.enumerated() {
            // dailyStatusのindexをdayOfWeek.allCasesのindexとして曜日情報を取得
            // dailyStatusの要素数はdayOfWeek.allCasesの要素数と一致する前提
            guard let dayCase = dayOfWeek.allCases[safe: index] else {
                // このケースは現状のロジックでは発生しない想定
                print("Error: dailyStatus count mismatch with dayOfWeek.allCases")
                continue
            }

            let date = Date(timeIntervalSince1970: TimeInterval(status.updatedTimeStamp))
            let isUpdatedInTab = status.isUpdated

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            let dateText = dateFormatter.string(from: date)
            let dayOfWeekText = dayCase.displayName

            let displayInfo = DayDisplayInfo(dateText: dateText, dayOfWeekText: dayOfWeekText, isUpdated: isUpdatedInTab)
            currentDisplayInfos.append(displayInfo)

            let button = WeeklyTabButton()
            button.configure(dayInfo: displayInfo, isSelected: index == selectedIndex)
            button.tag = index
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            tabButtons.append(button)
        }
        updateSelection()
    }

    private func updateSelection() {
        for (i, button) in tabButtons.enumerated() {
            if let dayInfo = currentDisplayInfos[safe: i] {
                 button.configure(dayInfo: dayInfo, isSelected: i == selectedIndex)
            }
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        let index = sender.tag
        if selectedIndex != index {
            selectedIndex = index
        }
        onSelect?(index)
    }
}

final class WeeklyTabButton: UIButton {

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: - Internal

    func configure(dayInfo: WeeklyTabBarView.DayDisplayInfo, isSelected: Bool) {
        self.currentDayInfo = dayInfo

        dateLabel.text = dayInfo.dateText
        dayOfWeekLabel.text = dayInfo.dayOfWeekText

        if isSelected, dayInfo.isUpdated {
            dateLabel.textColor = .white
            dayOfWeekLabel.textColor = .white
            canvasView.backgroundColor = UIColor(hex: "FB4747")
            upBadge.backgroundColor = .white
            upBadge.textColor = UIColor(hex: "FB4747")
        } else if isSelected {
            dateLabel.textColor = UIColor.black.withAlphaComponent(0.94)
            dayOfWeekLabel.textColor = UIColor.black.withAlphaComponent(0.94)
            canvasView.backgroundColor = .white
        } else {
            dateLabel.textColor = UIColor.white.withAlphaComponent(0.4)
            dayOfWeekLabel.textColor = UIColor.white.withAlphaComponent(0.4)
            canvasView.backgroundColor = .clear
            upBadge.backgroundColor = UIColor(hex: "FB4747")
            upBadge.textColor = .white
        }

        upBadge.isHidden = !dayInfo.isUpdated
    }

    // MARK: - Private

    private(set) var currentDayInfo: WeeklyTabBarView.DayDisplayInfo?

    private let canvasView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let upBadge: UILabel = {
        let label = UILabel()
        label.text = "UP"
        label.textColor = .white
        label.backgroundColor = UIColor(hex: "FF4747")
        label.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    private func setupViews() {
        addSubview(canvasView)
        canvasView.addSubview(dateLabel)
        canvasView.addSubview(dayOfWeekLabel)
        addSubview(upBadge)
    }

    private func configureLayout() {
        canvasView.pin.horizontally().vCenter().size(48)
        dateLabel.pin.top(10).hCenter().height(10).sizeToFit(.height)
        dayOfWeekLabel.pin.bottom(10).hCenter().height(14).sizeToFit(.height)
        let badgeSize = CGSize(width: 22, height: 14)
        upBadge.pin.top(1).hCenter().size(badgeSize)
    }
}
