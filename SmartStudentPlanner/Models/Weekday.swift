import Foundation

/// Represents days of the week, aligned with Apple's Gregorian Calendar weekday components.
/// Apple Calendar convention: Sunday = 1, Monday = 2, Tuesday = 3, ..., Saturday = 7.
enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    /// Full weekday name (e.g., "Monday").
    var fullName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    /// Short 3-letter weekday abbreviation (e.g., "Mon").
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }

    /// Single character symbol (e.g., "M").
    var singleLetter: String {
        String(shortName.prefix(1))
    }

    /// Returns the current day of the week according to the user's current calendar.
    static var current: Weekday {
        let weekdayInt = Calendar.current.component(.weekday, from: Date())
        return Weekday(rawValue: weekdayInt) ?? .monday
    }

    /// Standard academic week order starting on Monday and ending on Sunday.
    static var academicWeek: [Weekday] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}
