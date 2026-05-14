import SwiftUI

struct GoalProgressRing: View {
    let fraction: Double
    var lineWidth: CGFloat = 12
    var size: CGFloat = 140

    private var clamped: Double {
        min(max(fraction, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AngularGradient(
                        colors: [.teal, .mint, .cyan],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int((clamped * 100).rounded()))%")
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(width: size, height: size)
        .animation(.spring(duration: 0.45), value: clamped)
    }
}

#Preview {
    GoalProgressRing(fraction: 0.37)
                .padding()
}
