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
                    VStack(alignment: .leading, spacing: 14) {
                        if let data = goal.photoData, let uiImage = GoalImageCache.uiImage(for: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCorner, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: AppTheme.cardCorner, style: .continuous)
                                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                                }
                                .accessibilityLabel("Photo of item")
                        }
                        if let url = goal.productURL {
                            Button {
                                Haptics.light()
                                openURL(url)
                            } label: {
                                Label("Open product link", systemImage: "safari.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.accent)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
                .listRowBackground(Color.clear)
            }

            Section {
                VStack(spacing: 18) {
                    GoalProgressRing(fraction: goal.progressFraction, lineWidth: 14, size: 168)

                    if goal.isComplete {
                        Label("You reached this goal", systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.accent.opacity(0.14))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 10) {
                        metricPill(title: "Saved", value: goal.savedAmount)
                        metricPill(title: "Target", value: goal.targetAmount)
                        metricPill(title: "Left", value: goal.amountRemaining)
                    }

                    if let targetDate = goal.targetDate {
                        Label {
                            Text(targetDate, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .listRowBackground(Color.clear)
            }

            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 10)], spacing: 10) {
                    ForEach(Array(quickAmounts.enumerated()), id: \.offset) { _, amount in
                        Button {
                            applyContribution(amount)
                        } label: {
                            Text(amount, format: .currency(code: AppCurrency.code))
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.accent)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            } header: {
                Text("Quick add")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Section {
                HStack(spacing: 12) {
                    TextField("Amount", text: $contributionText)
                        .keyboardType(.decimalPad)
                        .focused($contributionFocused)
                        .font(.body.monospacedDigit())
                    Button("Add") {
                        if let v = parsedContribution { applyContribution(v) }
                    }
                    .fontWeight(.semibold)
                    .disabled(parsedContribution == nil || (parsedContribution ?? 0) <= 0)
                }
            } header: {
                Text("Custom amount")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            Section {
                HStack(spacing: 12) {
                    TextField("Amount to remove", text: $withdrawText)
                        .keyboardType(.decimalPad)
                        .focused($withdrawFocused)
                        .font(.body.monospacedDigit())
                    Button("Remove") {
                        applyWithdrawal()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .disabled(parsedWithdrawal == nil)
                }
                Text("Use this if you spent saved cash or need to correct a typo.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Move money out")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }

            if !goal.notes.isEmpty {
                Section("Notes") {
                    Text(goal.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.screenBackground())
        .listStyle(.insetGrouped)
        .scrollDismissesKeyboard(.interactively)
        .keyboardDismissToolbar()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "square.and.pencil") {
                    Haptics.selection()
                    showingEdit = true
                }
                .accessibilityLabel("Edit goal")
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditGoalView(goal: goal)
                .presentationDragIndicator(.visible)
        }
    }

    private func metricPill(title: String, value: Decimal) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value, format: .currency(code: AppCurrency.code))
                .font(.footnote.weight(.semibold))
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: AppTheme.cardCornerSmall, style: .continuous)
                .fill(AppTheme.cardSurface)
        }
        .accessibilityElement(children: .combine)
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
        let wasIncomplete = !goal.isComplete
        withAnimation(AppMotion.modelUpdate) {
            goal.savedAmount += amount
        }
        contributionText = ""
        contributionFocused = false
        Haptics.medium()
        if wasIncomplete, goal.isComplete {
            Haptics.success()
        }
    }

    private func applyWithdrawal() {
        guard let sub = parsedWithdrawal, sub > 0 else { return }
        withAnimation(AppMotion.modelUpdate) {
            goal.savedAmount = max(goal.savedAmount - sub, Decimal(0))
        }
        withdrawText = ""
        withdrawFocused = false
        Haptics.light()
    }
}
