import Foundation

enum ProductLinkHelpers {
    /// Turns user-pasted text into a URL, adding `https://` when no scheme is present.
    static func openableURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(trimmed)")
    }
}
