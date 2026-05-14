import SwiftData
import SwiftUI

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetText = ""
    @State private var hasDeadline = false
    @State private var targetDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("What are you saving for?", text: $name)
                    TextField("Target amount", text: $targetText)
                        .keyboardType(.decimalPad)
                }
                Section("Optional") {
                    Toggle("Set a target date", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                }
            }
            .navigationTitle("New goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private var parsedTarget: Decimal? {
        let t = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        return Decimal(string: t, locale: Locale.current)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (parsedTarget ?? 0) > 0
    }

    private func save() {
        guard let target = parsedTarget, target > 0 else { return }
        let goal = SavingsGoal(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: target,
            targetDate: hasDeadline ? targetDate : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(goal)
        dismiss()
    }
}
