import UIKit

/// Decodes and caches `UIImage` from goal photo bytes so scrolling does not re-decode JPEG/HEIC every frame.
enum GoalImageCache {
    private static let cache: NSCache<NSData, UIImage> = {
        let c = NSCache<NSData, UIImage>()
        c.countLimit = 48
        c.totalCostLimit = 36 * 1024 * 1024
        return c
    }()

    static func uiImage(for data: Data) -> UIImage? {
        let key = data as NSData
        if let hit = cache.object(forKey: key) {
            return hit
        }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: key, cost: data.count)
        return image
    }
}
