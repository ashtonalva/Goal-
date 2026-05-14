import SwiftUI
import SwiftData

@main
struct GoalBudgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavingsGoal.self)
    }
}
