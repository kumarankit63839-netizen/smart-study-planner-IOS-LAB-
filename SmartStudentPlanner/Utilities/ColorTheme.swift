import SwiftUI

/// Design tokens, color palette, and color utility extensions.
enum ColorTheme {
    // Primary Indigo/Blue Accents
    static let primaryIndigo = Color(hex: "#4F46E5")
    static let electricBlue = Color(hex: "#2563EB")
    static let skyBlue = Color(hex: "#0EA5E9")
    static let mintGreen = Color(hex: "#10B981")
    static let amberOrange = Color(hex: "#F59E0B")
    static let coralRed = Color(hex: "#EF4444")
    static let violetPurple = Color(hex: "#8B5CF6")
    static let rosePink = Color(hex: "#EC4899")

    /// Curated palette for timetable classes and subjects.
    static let classColors: [ClassColorOption] = [
        ClassColorOption(name: "Indigo", hex: "#4F46E5"),
        ClassColorOption(name: "Blue", hex: "#2563EB"),
        ClassColorOption(name: "Teal", hex: "#0D9488"),
        ClassColorOption(name: "Emerald", hex: "#059669"),
        ClassColorOption(name: "Purple", hex: "#7C3AED"),
        ClassColorOption(name: "Pink", hex: "#DB2777"),
        ClassColorOption(name: "Amber", hex: "#D97706"),
        ClassColorOption(name: "Rose", hex: "#E11D48")
    ]
}

struct ClassColorOption: Identifiable, Hashable {
    var id: String { hex }
    let name: String
    let hex: String
    
    var color: Color {
        Color(hex: hex)
    }
}

// MARK: - Color Hex Initializer
extension Color {
    /// Initializes a SwiftUI Color from a hexadecimal string (e.g., "#4F46E5" or "4F46E5").
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 79, 70, 229) // Default Indigo fallback
        }

        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
    
    /// Converts SwiftUI Color to Hex String for persistence.
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#4F46E5"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

// MARK: - Common Card Modifier
struct ModernCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var elevation: CGFloat = 2

    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: elevation * 2, x: 0, y: elevation)
    }
}

extension View {
    func modernCardStyle(cornerRadius: CGFloat = 16, elevation: CGFloat = 2) -> some View {
        self.modifier(ModernCardModifier(cornerRadius: cornerRadius, elevation: elevation))
    }
}
