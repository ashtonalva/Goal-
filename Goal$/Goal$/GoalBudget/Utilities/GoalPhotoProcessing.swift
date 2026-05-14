import UIKit

enum GoalPhotoProcessing {
    /// Keeps storage small and list scrolling smooth.
    static func prepareForStorage(_ data: Data, maxDimension: CGFloat = 1200, jpegQuality: CGFloat = 0.75) -> Data {
        guard let image = UIImage(data: data) else { return data }
        let largest = max(image.size.width, image.size.height)
        guard largest > maxDimension else {
            return image.jpegData(compressionQuality: jpegQuality) ?? data
        }
        let scale = maxDimension / largest
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: jpegQuality) ?? data
    }
}
