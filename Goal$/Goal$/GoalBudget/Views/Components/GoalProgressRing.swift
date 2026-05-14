import SwiftUI

struct GoalProgressRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let fraction: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 140
    /// Drop the glow on tiny rings (e.g. list rows) to save compositing cost while scrolling.
    var showGlow: Bool = true

    private var clamped: Double {
        min(max(fraction, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AppTheme.ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: showGlow ? AppTheme.accent.opacity(0.35) : .clear,
                    radius: (showGlow && clamped > 0) ? 4 : 0,
                    y: 0
                )
            Text("\(Int((clamped * 100).rounded()))%")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .contentTransition(AppMotion.percentTransition(reduceMotion: reduceMotion))
        }
        .frame(width: size, height: size)
        .animation(AppMotion.ringAnimation(reduceMotion: reduceMotion), value: clamped)
    }
}

#Preview {
    GoalProgressRing(fraction: 0.37)
        .padding()
        .background(AppTheme.canvas)
}
