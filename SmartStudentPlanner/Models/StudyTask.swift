import Foundation
import SwiftData

/// Represents a student's study task, assignment, or project.
/// Persisted locally using Apple's SwiftData framework (iOS 17+).
@Model
final class StudyTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var subject: String
    var dueDate: Date
    var priorityRaw: String
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var hasReminder: Bool
    var reminderDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        subject: String,
        dueDate: Date,
        priority: Priority = .medium,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        hasReminder: Bool = false,
        reminderDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.subject = subject
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.hasReminder = hasReminder
        self.reminderDate = reminderDate
    }

    /// Computed property wrapping the string-persisted priority rawValue into a typed enum.
    var priority: Priority {
        get {
            Priority(rawValue: priorityRaw) ?? .medium
        }
        set {
            priorityRaw = newValue.rawValue
        }
    }

    /// Indicates whether the task is past its due date and not yet marked completed.
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }

    /// Formatted representation of the task's due date.
    var formattedDueDate: String {
        DateHelpers.formatDate(dueDate)
    }

    /// Formatted time component for the due date.
    var formattedDueTime: String {
        DateHelpers.formatTime(dueDate)
    }

    /// Relative countdown string (e.g., "Due in 2 days" or "Overdue by 3 hours").
    var dueCountdown: String {
        DateHelpers.relativeTimeString(from: dueDate, isCompleted: isCompleted)
    }
}
