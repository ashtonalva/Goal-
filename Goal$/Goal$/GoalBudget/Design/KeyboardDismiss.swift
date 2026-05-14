import SwiftUI
import UIKit

extension View {
    /// Adds a **Done** button above the keyboard (for decimal pad and similar).
    func keyboardDismissToolbar() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
                .fontWeight(.semibold)
                .tint(AppTheme.accent)
            }
        }
    }
}
