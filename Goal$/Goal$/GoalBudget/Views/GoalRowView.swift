import SwiftUI
import UIKit

struct GoalRowView: View {
    let goal: SavingsGoal

    private var percentLabel: String {
        "\(Int((goal.progressFraction * 100).rounded()))%"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            itemVisual

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    Text(percentLabel)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                        .monospacedDigit()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accent.opacity(0.15))
                        .clipShape(Capsule())
                }

                if goal.isComplete {
                    Label("Funded", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                }

                ProgressView(value: goal.progressFraction)
                    .tint(AppTheme.accent)
                    .animation(AppMotion.progressBar, value: goal.progressFraction)

                HStack(spacing: 4) {
                    Text(goal.savedAmount, format: .currency(code: AppCurrency.code))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("of")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(goal.targetAmount, format: .currency(code: AppCurrency.code))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if goal.productURL != nil {
                    Label("Product link", systemImage: "link.circle.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var itemVisual: some View {
        if let data = goal.photoData, let image = GoalImageCache.uiImage(for: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerSmall, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerSmall, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                }
                .accessibilityLabel("Item photo")
        } else {
            GoalProgressRing(fraction: goal.progressFraction, lineWidth: 5, size: 56, showGlow: false)
                .accessibilityHidden(true)
        }
    }
}
