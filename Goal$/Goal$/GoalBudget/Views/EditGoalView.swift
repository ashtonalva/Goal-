import SwiftData
import SwiftUI

struct EditGoalView: View {
    @Bindable var goal: SavingsGoal
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetText: String = ""
    @State private var productLink: String = ""
    @State private var photoData: Data?
    @State private var hasDeadline = false
    @State private var targetDate = Date()
    @State private var notes: String = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name this goal", text: $name)
                } header: {
                    Text("Name")
                } footer: {
                    Text("What you’re saving for.")
                }

                Section {
                    TextField("Amount to save", text: $targetText)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Savings target")
                } footer: {
                    Text("Must be at least what you’ve already saved.")
                }

                Section {
                    GoalPhotoPickerBlock(photoData: $photoData)
                } header: {
                    Text("Photo")
                } footer: {
                    Text("Picture of the item you want.")
                }

                Section {
                    TextField("https://…", text: $productLink)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Product link")
                } footer: {
                    Text("Store or product page. https:// is optional.")
                }

                Section {
                    Toggle("Target date", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 8)
                } header: {
                    Text("Optional")
                }
            }
            .navigationTitle("Edit goal")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = goal.name
                targetText = AppCurrency.editingString(for: goal.targetAmount)
                productLink = goal.productLink
                photoData = goal.photoData
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
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .alert("Check amounts", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.screenBackground())
        .scrollDismissesKeyboard(.interactively)
        .keyboardDismissToolbar()
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
        withAnimation(AppMotion.modelUpdate) {
            goal.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.targetAmount = target
            goal.productLink = productLink.trimmingCharacters(in: .whitespacesAndNewlines)
            goal.photoData = photoData
            goal.targetDate = hasDeadline ? targetDate : nil
            goal.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        Haptics.medium()
        dismiss()
    }
}
