import Foundation
import SwiftData
import SwiftUI

/// Represents a scheduled college class session in the student's timetable.
/// Persisted locally via SwiftData (iOS 17+).
@Model
final class ClassSession {
    @Attribute(.unique) var id: UUID
    var subject: String
    var teacherName: String
    var roomNumber: String
    var weekdayRaw: Int
    var startTime: Date
    var endTime: Date
    var colorHex: String

    init(
        id: UUID = UUID(),
        subject: String,
        teacherName: String = "",
        roomNumber: String = "",
        weekday: Weekday = .monday,
        startTime: Date,
        endTime: Date,
        colorHex: String = "#4F46E5"
    ) {
        self.id = id
        self.subject = subject
        self.teacherName = teacherName
        self.roomNumber = roomNumber
        self.weekdayRaw = weekday.rawValue
        self.startTime = startTime
        self.endTime = endTime
        self.colorHex = colorHex
    }

    /// Computed property wrapping the weekday integer into a strongly-typed enum.
    var weekday: Weekday {
        get {
            Weekday(rawValue: weekdayRaw) ?? .monday
        }
        set {
            weekdayRaw = newValue.rawValue
        }
    }

    /// Formatted time string range (e.g. "09:00 AM - 10:30 AM").
    var formattedTimeRange: String {
        let start = DateHelpers.formatTime(startTime)
        let end = DateHelpers.formatTime(endTime)
        return "\(start) - \(end)"
    }

    /// Duration of class session in minutes.
    var durationMinutes: Int {
        let interval = endTime.timeIntervalSince(startTime)
        return max(0, Int(interval / 60))
    }

    /// Formatted duration (e.g. "1 hr 30 min" or "45 min").
    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours) hr"
        } else {
            return "\(minutes) min"
        }
    }

    /// Returns a SwiftUI Color corresponding to the stored hexadecimal color.
    var displayColor: Color {
        Color(hex: colorHex)
    }

    /// Checks if this class session overlaps in time with another class session on the same weekday.
    func overlaps(with other: ClassSession) -> Bool {
        guard self.id != other.id, self.weekday == other.weekday else {
            return false
        }
        return DateHelpers.timeRangesOverlap(
            start1: self.startTime,
            end1: self.endTime,
            start2: other.startTime,
            end2: other.endTime
        )
    }
}
