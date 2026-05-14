import SwiftUI
import UIKit

struct GoalDetailView: View {
    @Bindable var goal: SavingsGoal
    @Environment(\.openURL) private var openURL
    @State private var contributionText = ""
    @State private var withdrawText = ""
    @State private var showingEdit = false
    @FocusState private var contributionFocused: Bool
    @FocusState private var withdrawFocused: Bool

    private let quickAmounts: [Decimal] = [5, 10, 25, 50, 100].map { Decimal($0) }

    var body: some View {
        List {
            if goal.photoData != nil || goal.productURL != nil {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if let data = goal.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .accessibilityLabel("Photo of item")
                        }
                        if let url = goal.productURL {
                            Button {
                                openURL(url)
                            } label: {
                                Label("Open product link", systemImage: "safari")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.teal)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }

            Section {
                VStack(spacing: 16) {
                    GoalProgressRing(fraction: goal.progressFraction, lineWidth: 14, size: 160)

                    if goal.isComplete {
                        Label("You reached this goal", systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.green)
                    }

                    HStack(spacing: 20) {
                        metric(title: "Saved", value: goal.savedAmount)
                        metric(title: "Target", value: goal.targetAmount)
                        metric(title: "Left", value: goal.amountRemaining)
                    }
                    .frame(maxWidth: .infinity)

                    if let targetDate = goal.targetDate {
                        Label {
                            Text(targetDate, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Quick add") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], spacing: 8) {
                    ForEach(Array(quickAmounts.enumerated()), id: \.offset) { _, amount in
                        Button {
                            applyContribution(amount)
                        } label: {
                            Text(amount, format: .currency(code: AppCurrency.code))
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section("Custom amount") {
                HStack {
                    TextField("Amount", text: $contributionText)
                        .keyboardType(.decimalPad)
                        .focused($contributionFocused)
                    Button("Add") {
                        if let v = parsedContribution { applyContribution(v) }
                    }
                    .disabled(parsedContribution == nil || (parsedContribution ?? 0) <= 0)
                }
            }

            Section("Move money out") {
                HStack {
                    TextField("Amount to remove", text: $withdrawText)
                        .keyboardType(.decimalPad)
                        .focused($withdrawFocused)
                    Button("Remove") {
                        applyWithdrawal()
                    }
                    .disabled(parsedWithdrawal == nil)
                }
                Text("Use this if you spent saved cash or need to correct a typo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !goal.notes.isEmpty {
                Section("Notes") {
                    Text(goal.notes)
                }
            }
        }
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditGoalView(goal: goal)
        }
    }

    private func metric(title: String, value: Decimal) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value, format: .currency(code: AppCurrency.code))
                .font(.subheadline.weight(.semibold))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var parsedContribution: Decimal? {
        parseMoney(contributionText)
    }

    private var parsedWithdrawal: Decimal? {
        parseMoney(withdrawText)
    }

    private func parseMoney(_ raw: String) -> Decimal? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Decimal(string: trimmed, locale: Locale.current)
    }

    private func applyContribution(_ amount: Decimal) {
        guard amount > 0 else { return }
        goal.savedAmount += amount
        contributionText = ""
        contributionFocused = false
    }

    private func applyWithdrawal() {
        guard let sub = parsedWithdrawal, sub > 0 else { return }
        goal.savedAmount = max(goal.savedAmount - sub, Decimal(0))
        withdrawText = ""
        withdrawFocused = false
    }
}
