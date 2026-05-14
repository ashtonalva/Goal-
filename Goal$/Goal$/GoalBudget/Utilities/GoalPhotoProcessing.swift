import UIKit

enum GoalPhotoProcessing {
    /// Smaller max dimension + slightly lower quality = faster resize, encode, and decode in lists.
    static func prepareForStorage(_ data: Data, maxDimension: CGFloat = 960, jpegQuality: CGFloat = 0.66) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let largest = max(image.size.width, image.size.height)
        guard largest > maxDimension else {
            return image.jpegData(compressionQuality: jpegQuality) ?? data
        }
        let scale = maxDimension / largest
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = min(format.scale, 2)
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: jpegQuality) ?? data
    }
}
