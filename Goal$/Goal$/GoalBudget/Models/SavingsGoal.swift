import Foundation
import SwiftData

@Model
final class SavingsGoal {
    var name: String
    var targetAmount: Decimal
    var savedAmount: Decimal
    var createdAt: Date
    var targetDate: Date?
    var notes: String

    init(
        name: String,
        targetAmount: Decimal,
        savedAmount: Decimal = 0,
        targetDate: Date? = nil,
        notes: String = ""
    ) {
        self.name = name
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.createdAt = Date()
        self.targetDate = targetDate
        self.notes = notes
    }

    /// 0...1 for progress UI
    var progressFraction: Double {
        let t = (targetAmount as NSDecimalNumber).doubleValue
        guard t > 0 else { return 0 }
        let s = (savedAmount as NSDecimalNumber).doubleValue
        return min(max(s / t, 0), 1)
    }

    var amountRemaining: Decimal {
        max(targetAmount - savedAmount, 0)
    }

    var isComplete: Bool {
        progressFraction >= 1
    }
}
