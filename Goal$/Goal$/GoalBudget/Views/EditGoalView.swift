import SwiftData
import SwiftUI

struct EditGoalView: View {
    @Bindable var goal: SavingsGoal
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetText: String = ""
    @State private var hasDeadline = false
    @State private var targetDate = Date()
    @State private var notes: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Name", text: $name)
                    TextField("Target amount", text: $targetText)
                        .keyboardType(.decimalPad)
                }
                Section("Optional") {
                    Toggle("Target date", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 8)
                }
            }
            .navigationTitle("Edit goal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = goal.name
                targetText = AppCurrency.editingString(for: goal.targetAmount)
                hasDeadline = goal.targetDate != nil
                targetDate = goal.targetDate ?? Date()
                notes = goal.notes
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .alert("Check amounts", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
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
        if target < goal.savedAmount {
            validationMessage =
                "Target must be at least what you’ve already saved (\(goal.savedAmount.formattedMoney()))."
            showValidationAlert = true
            return
        }
        goal.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.targetAmount = target
        goal.targetDate = hasDeadline ? targetDate : nil
        goal.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        dismiss()
    }
}
