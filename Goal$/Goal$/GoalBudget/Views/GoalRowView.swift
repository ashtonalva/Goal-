import SwiftUI
import UIKit

struct GoalRowView: View {
    let goal: SavingsGoal

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            itemVisual

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if goal.isComplete {
                        Text("Done")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.2))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }

                ProgressView(value: goal.progressFraction)
                    .tint(.teal)

                HStack(spacing: 4) {
                    Text(goal.savedAmount, format: .currency(code: AppCurrency.code))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("of")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(goal.targetAmount, format: .currency(code: AppCurrency.code))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if goal.productURL != nil {
                    Label("Has link", systemImage: "link")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var itemVisual: some View {
        if let data = goal.photoData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.quaternary, lineWidth: 1)
                }
                .accessibilityLabel("Item photo")
        } else {
            GoalProgressRing(fraction: goal.progressFraction, lineWidth: 5, size: 52)
                .accessibilityHidden(true)
        }
    }
}
