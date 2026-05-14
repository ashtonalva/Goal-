import SwiftUI

/// Fast, lightweight motion used across Goal$.
enum AppMotion {
    /// Progress ring and similar continuous values.
    static let progressSpring = Animation.spring(response: 0.26, dampingFraction: 0.88)

    /// SwiftData / visible totals after a user action.
    static let modelUpdate = Animation.spring(response: 0.28, dampingFraction: 0.9)

    /// Linear bar motion (cheap on the GPU).
    static let progressBar = Animation.linear(duration: 0.16)

    static func ringAnimation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.12) : progressSpring
    }

    static func percentTransition(reduceMotion: Bool) -> ContentTransition {
        reduceMotion ? .opacity : .numericText()
    }
}
