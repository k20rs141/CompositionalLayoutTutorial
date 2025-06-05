import UIKit
import PinLayout

final class PreviewThumbnailCell: UICollectionViewCell {
    static let reuseIdentifier = "PreviewThumbnailCell"

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
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

    func configure(tab: PreviewTab, isSelected: Bool) {
        favoriteImageView.loadImage(with: tab.chapterPagesList.chapterPages.first?.favoriteImageURL ?? URL(string: "")!)
        favoriteImageView.layer.borderWidth = isSelected ? 2 : 0.5
        favoriteImageView.layer.borderColor = isSelected ? UIColor(hex: "DC0914").cgColor : UIColor(hex: "6E6F75").cgColor
        favoriteImageView.layer.opacity = isSelected ? 1 : 0.3
    }

    // MARK: - Private

    private let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private func setupViews() {
        contentView.addSubview(favoriteImageView)
    }

    private func configureLayout() {
        favoriteImageView.pin.all()
    }
} 