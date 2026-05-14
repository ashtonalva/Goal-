import SwiftUI

/// Black-first palette with **green** accents and **white** type on hero surfaces.
enum AppTheme {
    static let cardCorner: CGFloat = 16
    static let cardCornerSmall: CGFloat = 12

    /// Near-black canvas.
    static let canvas = Color(red: 0.02, green: 0.02, blue: 0.02)
    /// Slightly lifted black for layered UI.
    static let canvasElevated = Color(red: 0.05, green: 0.05, blue: 0.05)

    /// Cards / rows on top of black.
    static let cardSurface = Color(red: 0.12, green: 0.12, blue: 0.12)

    /// Primary accent — vivid green.
    static let accent = Color(red: 0.22, green: 0.88, blue: 0.45)
    /// Darker green for depth and rings.
    static let accentDeep = Color(red: 0.04, green: 0.42, blue: 0.22)
    static let accentMuted = Color(red: 0.14, green: 0.62, blue: 0.36)

    static var cardShadow: Color {
        Color.black.opacity(0.6)
    }

    static func screenBackground() -> some View {
        ZStack {
            canvas
            LinearGradient(
                colors: [
                    accentDeep.opacity(0.45),
                    Color.clear,
                    canvas,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [accent.opacity(0.2), .clear],
                center: UnitPoint(x: 0.5, y: 0.02),
                startRadius: 20,
                endRadius: 480
            )
        }
        .ignoresSafeArea()
    }

    /// Overview hero: black and deep green with white copy on top.
    static var overviewGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentDeep.opacity(0.92),
                Color(red: 0.04, green: 0.07, blue: 0.05),
                canvas,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var overviewStroke: LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.55), Color.white.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var ringGradient: AngularGradient {
        AngularGradient(
            colors: [accent, accentMuted, Color.white.opacity(0.9), accent],
            center: .center
        )
    }
}
