import UIKit

/// Reuses generator instances so taps do not allocate new UIKit feedback objects each time.
enum Haptics {
    private static let lightGen = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private static let notificationGen = UINotificationFeedbackGenerator()
    private static let selectionGen = UISelectionFeedbackGenerator()

    static func light() {
        lightGen.impactOccurred()
    }

    static func medium() {
        mediumGen.impactOccurred()
    }

    static func success() {
        notificationGen.notificationOccurred(.success)
    }

    static func warning() {
        notificationGen.notificationOccurred(.warning)
    }

    static func selection() {
        selectionGen.selectionChanged()
    }

    /// Call once when the main screen appears so the first tap feels instant.
    static func prepareEngines() {
        lightGen.prepare()
        mediumGen.prepare()
        selectionGen.prepare()
        notificationGen.prepare()
    }
}
