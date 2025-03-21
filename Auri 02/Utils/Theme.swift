import SwiftUI

struct Theme {
    static let backgroundPrimary = Color(red: 0.1, green: 0.1, blue: 0.1) // Muted black
    static let backgroundSecondary = Color(red: 0.15, green: 0.15, blue: 0.15) // Slightly lighter black
    static let accentColor = Color.blue
    
    // Custom font extensions
    static func sfProText(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    static func newYorkHeadline(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

// End of file
