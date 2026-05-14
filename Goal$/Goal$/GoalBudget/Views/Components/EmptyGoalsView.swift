import SwiftUI

struct EmptyGoalsView: View {
    let onCreateGoal: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.18))
                    .frame(width: 120, height: 120)
                Image(systemName: "target")
                    .font(.system(size: 48, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppTheme.accent)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Start a new goal")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(
                    "Give it a name, set how much you need to save, and add a photo plus a link to the item you want."
                )
                .font(.body)
                .foregroundStyle(Color.white.opacity(0.62))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            }

            Button(action: onCreateGoal) {
                Label("Create your first goal", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .padding()
    }
}

#Preview {
    EmptyGoalsView(onCreateGoal: {})
        .background(AppTheme.screenBackground())
}
