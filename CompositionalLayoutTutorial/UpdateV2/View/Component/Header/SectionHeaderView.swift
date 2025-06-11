import UIKit
import PinLayout

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    static let elementKind = "section-header-element-kind"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
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

    func configure(sectionType: Section, title: String) {
        self.sectionType = sectionType
        titleLabel.text = title
    }

    // MARK: - Private

    private var sectionType: Section?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private func configureLayout() {
        if sectionType == .preview {
            titleLabel.pin.horizontally(16).vertically()
        } else {
            titleLabel.pin.horizontally().vertically()
        }
    }
}
