import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.createdAt, order: .reverse) private var goals: [SavingsGoal]
    @State private var showingAddGoal = false

    private var orderedGoals: [SavingsGoal] {
        goals.sorted { a, b in
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
                    ContentUnavailableView(
                        "Start a new goal",
                        systemImage: "banknote",
                        description: Text(
                            "Give it a name, set how much you need to save, and add a photo plus a link to the item you want."
                        )
                    )
                } else {
                    List {
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Overview")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Saved across goals")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(totalSaved, format: .currency(code: AppCurrency.code))
                                            .font(.title2.weight(.semibold))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Combined target")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(totalTarget, format: .currency(code: AppCurrency.code))
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                ProgressView(value: overallProgress)
                                    .tint(.teal)
                            }
                            .padding(.vertical, 4)
                        }

                        Section("Your goals") {
                            ForEach(orderedGoals) { goal in
                                NavigationLink {
                                    GoalDetailView(goal: goal)
                                } label: {
                                    GoalRowView(goal: goal)
                                }
                            }
                            .onDelete(perform: deleteGoals)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Goal$")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add goal", systemImage: "plus") {
                        showingAddGoal = true
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
        }
    }

    private func deleteGoals(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(orderedGoals[index])
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavingsGoal.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
