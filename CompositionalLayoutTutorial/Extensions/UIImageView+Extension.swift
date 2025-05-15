import NukeExtensions
import UIKit

extension UIImageView {
    /// Nukeを使用して画像をロードし、フェードイン効果をつける
    /// - Parameters:
    ///   - url: 画像のURL
    ///   - placeholder: プレースホルダー画像（オプション）
    ///   - transitionDuration: フェードイン時間（デフォルト: 0.33秒）
    func loadImage(with url: URL?, 
                  placeholder: UIImage? = nil,
                  transitionDuration: TimeInterval = 0.33) {
        guard let url = url else {
            self.image = placeholder
            return
        }
        
        let options = ImageLoadingOptions(
            placeholder: placeholder,
            transition: .fadeIn(duration: transitionDuration)
        )
        
        NukeExtensions.loadImage(with: url, options: options, into: self)
    }
}
