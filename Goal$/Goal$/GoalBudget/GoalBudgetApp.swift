import SwiftData
import SwiftUI
import UIKit

@main
struct GoalBudgetApp: App {
    init() {
        NavigationAppearance.apply()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(AppTheme.accent)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: SavingsGoal.self)
    }
}
