import PinLayout
import UIKit

final class DaySelectorHeader: UICollectionReusableView {
    static let reuseIdentifier = "DaySelectorHeader"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .cyan.withAlphaComponent(0.25)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: Internal

    func configure(with: [dayOfWeek], selectedDate: dayOfWeek) {
        
    }

    // MARK: - Private

    private func configureLayout() {
    }
}
