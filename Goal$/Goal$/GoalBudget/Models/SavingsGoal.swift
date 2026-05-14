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
    /// User-pasted product page URL (may omit https://).
    var productLink: String
    @Attribute(.externalStorage) var photoData: Data?

    init(
        name: String,
        targetAmount: Decimal,
        savedAmount: Decimal = 0,
        targetDate: Date? = nil,
        notes: String = "",
        productLink: String = "",
        photoData: Data? = nil
    ) {
        self.name = name
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.createdAt = Date()
        self.targetDate = targetDate
        self.notes = notes
        self.productLink = productLink
        self.photoData = photoData
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

    var productURL: URL? {
        ProductLinkHelpers.openableURL(from: productLink)
    }
}
