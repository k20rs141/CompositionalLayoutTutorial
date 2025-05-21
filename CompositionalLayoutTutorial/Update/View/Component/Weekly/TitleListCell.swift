import UIKit
import PinLayout

final class TitleListCell: UICollectionViewCell {
    static let reuseIdentifier = "MangaContentCell"

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.removeFromSuperview()
        addSubview(thumbnail)
        thumbnail.addSubview(upBadge)
        thumbnail.addSubview(newBadge)
        addSubview(titleName)
        addSubview(chapterLabel)
        addSubview(views)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = chapterLabel.frame.maxY
        return CGSize(width: size.width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    // MARK: Internal

    func configure(content: OriginalTitleGroup) {
        titleName.text = content.title
        chapterLabel.text = "#\(content.chapterNumber)"
        views.text = content.formattedViewCount

        switch content.titleUpdateStatus {
        case .up:
            upBadge.isHidden = false
            newBadge.isHidden = true
        case .new:
            upBadge.isHidden = true
            newBadge.isHidden = false
        case .reedition, .ourPicks, .none:
            upBadge.isHidden = true
            newBadge.isHidden = true
        }

        thumbnail.loadImage(with: content.titles.first?.portraitImageURL)
    }

    func configure(content: Title) {
        titleName.text = content.name
        chapterLabel.text = "#\(content.id)"
        views.text = content.formattedViewCount

        switch content.badgeType {
        case .up:
            upBadge.isHidden = false
            newBadge.isHidden = true
        case .new:
            upBadge.isHidden = true
            newBadge.isHidden = false
        case .reedition, .ourPicks, .none:
            upBadge.isHidden = true
            newBadge.isHidden = true
        }

        thumbnail.loadImage(with: content.portraitImageURL)
    }

    // MARK: Private

    private let thumbnail: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()

    private var upBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .upBadge)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private var newBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .newBadge)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private var titleName: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private let chapterLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        label.textColor = UIColor(hex: "EEEEEE")
        label.backgroundColor = UIColor(hex: "353535")
        label.padding = UIEdgeInsets(top: 2.5, left: 4, bottom: 2.5, right: 4)
        label.numberOfLines = 1
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()

    private let views: UILabel = {
        let label: UILabel = .init()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()

    private func configureLayout() {
        thumbnail.pin.top().horizontally().aspectRatio(2/3)
        if !upBadge.isHidden {
            upBadge.pin.topLeft(4).height(9%).aspectRatio()
            if !newBadge.isHidden {
                newBadge.pin.after(of: upBadge, aligned: .bottom).height(9%).aspectRatio(3/2)
            }
        } else {
            if !newBadge.isHidden {
                newBadge.pin.topLeft(4).height(9%).aspectRatio()
            }
        }
        titleName.pin.below(of: thumbnail, aligned: .left).horizontally().height(14).marginVertical(6)
        chapterLabel.pin.below(of: titleName, aligned: .left).height(16).sizeToFit(.height)
        views.pin.after(of: chapterLabel, aligned: .center).height(10).marginLeft(6).sizeToFit(.height)
    }
} 
