import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.createdAt, order: .reverse) private var goals: [SavingsGoal]
    @State private var showingAddGoal = false
    @State private var searchText = ""

    private var displayedGoals: [SavingsGoal] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var list = goals
        if !q.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(q) }
        }
        return list.sorted { a, b in
            if a.isComplete != b.isComplete {
                return !a.isComplete && b.isComplete
            }
            return a.createdAt > b.createdAt
        }
    }

    private var totalTarget: Decimal {
        goals.reduce(0) { $0 + $1.targetAmount }
    }

    private var totalSaved: Decimal {
        goals.reduce(0) { $0 + $1.savedAmount }
    }

    private var overallProgress: Double {
        let t = (totalTarget as NSDecimalNumber).doubleValue
        guard t > 0 else { return 0 }
        let s = (totalSaved as NSDecimalNumber).doubleValue
        return min(max(s / t, 0), 1)
    }

    var body: some View {
        NavigationStack {
            Group {
                if goals.isEmpty {
                    EmptyGoalsView {
                        Haptics.selection()
                        showingAddGoal = true
                    }
                } else {
                    List {
                        Section {
                            overviewCard
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        Section {
                            if displayedGoals.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                            } else {
                                ForEach(displayedGoals) { goal in
                                    NavigationLink {
                                        GoalDetailView(goal: goal)
                                    } label: {
                                        GoalRowView(goal: goal)
                                    }
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: AppTheme.cardCorner, style: .continuous)
                                            .fill(AppTheme.cardSurface)
                                            .shadow(
                                                color: AppTheme.cardShadow,
                                                radius: 6,
                                                y: 2
                                            )
                                    )
                                }
                                .onDelete(perform: deleteGoals)
                            }
                        } header: {
                            HStack {
                                Text("Your goals")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.white.opacity(0.55))
                                    .textCase(nil)
                                Spacer()
                                Text("\(goals.count) total")
                                    .font(.caption)
                                    .foregroundStyle(Color.white.opacity(0.35))
                            }
                            .padding(.bottom, 2)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .refreshable {
                        Haptics.light()
                    }
                }
            }
            .navigationTitle("Goal$")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search goals")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Haptics.selection()
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .accessibilityLabel("Add goal")
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .presentationDragIndicator(.visible)
            }
        }
        .background {
            AppTheme.screenBackground()
        }
        .onAppear {
            Haptics.prepareEngines()
        }
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Overview")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.85))
                    .tracking(0.8)
                Spacer()
                Text("\(Int((overallProgress * 100).rounded()))% overall")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .monospacedDigit()
            }

            HStack(alignment: .firstTextBaseline, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(totalSaved, format: .currency(code: AppCurrency.code))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Target")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(totalTarget, format: .currency(code: AppCurrency.code))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }

            ProgressView(value: overallProgress)
                .tint(AppTheme.accent)
                .scaleEffect(x: 1, y: 1.35, anchor: .center)
                .animation(AppMotion.progressBar, value: overallProgress)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.overviewGradient)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(AppTheme.overviewStroke, lineWidth: 1)
                }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Overview: saved \(totalSaved.formattedMoney()) of target \(totalTarget.formattedMoney()), \(Int((overallProgress * 100).rounded())) percent overall")
    }

    private func deleteGoals(at offsets: IndexSet) {
        Haptics.light()
        for index in offsets {
            modelContext.delete(displayedGoals[index])
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavingsGoal.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
