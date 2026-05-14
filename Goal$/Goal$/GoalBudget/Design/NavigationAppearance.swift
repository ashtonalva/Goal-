import UIKit

/// Transparent navigation so the app gradient shows through—no solid black bar.
enum NavigationAppearance {
    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        let titleShadow = NSShadow()
        titleShadow.shadowColor = UIColor.black.withAlphaComponent(0.45)
        titleShadow.shadowOffset = CGSize(width: 0, height: 1)
        titleShadow.shadowBlurRadius = 3

        let titleColor = UIColor.white
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .shadow: titleShadow,
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: titleColor,
            .shadow: titleShadow,
        ]

        let nav = UINavigationBar.appearance()
        nav.standardAppearance = appearance
        nav.scrollEdgeAppearance = appearance
        nav.compactAppearance = appearance
        nav.compactScrollEdgeAppearance = appearance
        nav.isTranslucent = true
        nav.tintColor = UIColor(red: 0.22, green: 0.88, blue: 0.45, alpha: 1)
    }
}
