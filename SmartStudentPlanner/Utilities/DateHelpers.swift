import Foundation

/// Centralized utility functions for date and time calculations across the application.
enum DateHelpers {
    
    // MARK: - Date Formatters
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    private static let shortDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Public Formatting Methods
    
    /// Formats a date to standard medium string (e.g., "Oct 9, 2026").
    static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    /// Formats a date with full weekday, month, day, year (e.g., "Thursday, October 9, 2026").
    static func formatFullDate(_ date: Date) -> String {
        fullDateFormatter.string(from: date)
    }
    
    /// Formats a date with abbreviated weekday and day (e.g., "Thu, Oct 9").
    static func formatShortDayDate(_ date: Date) -> String {
        shortDayDateFormatter.string(from: date)
    }
    
    /// Formats time component (e.g., "09:30 AM").
    static func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    /// Returns a warm, dynamic greeting based on the current hour of the day.
    static func greetingForCurrentTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    /// Provides a human-readable countdown or overdue status string.
    static func relativeTimeString(from date: Date, isCompleted: Bool) -> String {
        if isCompleted {
            return "Completed"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        if date < now {
            // Overdue
            let components = calendar.dateComponents([.day, .hour, .minute], from: date, to: now)
            if let days = components.day, days > 0 {
                return "Overdue by \(days) \(days == 1 ? "day" : "days")"
            } else if let hours = components.hour, hours > 0 {
                return "Overdue by \(hours) \(hours == 1 ? "hour" : "hours")"
            } else if let minutes = components.minute, minutes > 0 {
                return "Overdue by \(minutes)m"
            } else {
                return "Just overdue"
            }
        } else {
            // Future due date
            if calendar.isDateInToday(date) {
                return "Due today at \(formatTime(date))"
            } else if calendar.isDateInTomorrow(date) {
                return "Due tomorrow at \(formatTime(date))"
            }
            
            let components = calendar.dateComponents([.day, .hour], from: now, to: date)
            if let days = components.day, days > 0 {
                return "Due in \(days) \(days == 1 ? "day" : "days")"
            } else if let hours = components.hour, hours > 0 {
                return "Due in \(hours) \(hours == 1 ? "hour" : "hours")"
            } else {
                return "Due in less than an hour"
            }
        }
    }
    
    // MARK: - Time Range Overlap Validation
    
    /// Compares two time ranges solely by hour and minute components (ignoring the calendar day).
    /// Used for timetable clash/conflict detection.
    static func timeRangesOverlap(
        start1: Date,
        end1: Date,
        start2: Date,
        end2: Date
    ) -> Bool {
        let cal = Calendar.current
        
        let s1 = cal.component(.hour, from: start1) * 60 + cal.component(.minute, from: start1)
        let e1 = cal.component(.hour, from: end1) * 60 + cal.component(.minute, from: end1)
        let s2 = cal.component(.hour, from: start2) * 60 + cal.component(.minute, from: start2)
        let e2 = cal.component(.hour, from: end2) * 60 + cal.component(.minute, from: end2)
        
        // Interval [s1, e1) overlaps with [s2, e2) if max(s1, s2) < min(e1, e2)
        return max(s1, s2) < min(e1, e2)
    }
    
    /// Validates that an end time is strictly after a start time (in hours and minutes).
    static func isTimeOrderValid(start: Date, end: Date) -> Bool {
        let cal = Calendar.current
        let s = cal.component(.hour, from: start) * 60 + cal.component(.minute, from: start)
        let e = cal.component(.hour, from: end) * 60 + cal.component(.minute, from: end)
        return e > s
    }
    
    /// Utility helper to construct a specific date relative to now for previews and sample data.
    static func date(daysFromNow: Int, hour: Int = 18, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        if let currentDay = comps.day {
            comps.day = currentDay + daysFromNow
        }
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return calendar.date(from: comps) ?? Date()
    }
    
    /// Utility helper to construct a time-only date for timetable entries.
    static func time(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return calendar.date(from: comps) ?? Date()
    }
}
