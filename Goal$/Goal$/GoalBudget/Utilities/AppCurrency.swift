import Foundation

enum AppCurrency {
    static var code: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    /// Plain number string for amount text fields (locale-aware, no currency symbol).
    static func editingString(for decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: decimal as NSDecimalNumber) ?? ""
    }
}

extension Decimal {
    func formattedMoney() -> String {
        formatted(.currency(code: AppCurrency.code))
    }
}
