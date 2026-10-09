import SwiftUI

/// Defines priority levels for study tasks.
enum Priority: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }

    var title: String { rawValue }

    /// Sort weight used to sort tasks by urgency (High = 3, Medium = 2, Low = 1).
    var sortWeight: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }

    /// Associated theme color.
    var color: Color {
        switch self {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }

    /// Background tint color for badges and cards.
    var backgroundColor: Color {
        switch self {
        case .low:
            return Color.blue.opacity(0.12)
        case .medium:
            return Color.orange.opacity(0.12)
        case .high:
            return Color.red.opacity(0.12)
        }
    }

    /// SF Symbol icon name.
    var iconName: String {
        switch self {
        case .low:
            return "arrow.down"
        case .medium:
            return "equal"
        case .high:
            return "exclamationmark.3"
        }
    }
}
