import SwiftData
import SwiftUI

struct AddGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetText = ""
    @State private var productLink = ""
    @State private var photoData: Data?
    @State private var hasDeadline = false
    @State private var targetDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name this goal", text: $name)
                } header: {
                    Text("Name")
                } footer: {
                    Text("What you’re saving for—like “New laptop” or “Winter coat.”")
                }

                Section {
                    TextField("Amount to save", text: $targetText)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Savings target")
                } footer: {
                    Text("How much you need before you can buy it.")
                }

                Section {
                    GoalPhotoPickerBlock(photoData: $photoData)
                } header: {
                    Text("Photo")
                } footer: {
                    Text("Add a picture of the item so you remember what you’re working toward.")
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
                    Text("Paste a store or product page link. You can leave out https://—we’ll fill that in when you open it.")
                }

                Section {
                    Toggle("Set a target date", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3 ... 6)
                } header: {
                    Text("Optional")
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
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
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
        let goal = SavingsGoal(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            targetAmount: target,
            targetDate: hasDeadline ? targetDate : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            productLink: productLink.trimmingCharacters(in: .whitespacesAndNewlines),
            photoData: photoData
        )
        withAnimation(AppMotion.modelUpdate) {
            modelContext.insert(goal)
        }
        Haptics.medium()
        dismiss()
    }
}
