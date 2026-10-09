import Foundation
import SwiftData

/// Utility service to seed sample academic data into SwiftData for testing and demo purposes.
@MainActor
enum SampleDataService {
    
    /// Populates standard college tasks and timetable schedule.
    static func populateSampleData(in context: ModelContext) {
        // Sample Study Tasks
        let tasks = [
            StudyTask(
                title: "SwiftData & SwiftUI iOS Lab Report",
                taskDescription: "Document architecture, data models, and screenshots of the Smart Student Planner app.",
                subject: "Mobile Computing",
                dueDate: DateHelpers.date(daysFromNow: 1, hour: 17, minute: 0),
                priority: .high,
                isCompleted: false,
                hasReminder: true,
                reminderDate: DateHelpers.date(daysFromNow: 1, hour: 10, minute: 0)
            ),
            StudyTask(
                title: "Process Scheduling Simulation Report",
                taskDescription: "Compare turnaround time for FCFS, Round Robin, and Shortest Job First algorithms.",
                subject: "Operating Systems",
                dueDate: DateHelpers.date(daysFromNow: -1, hour: 23, minute: 59), // Intentionally overdue for testing
                priority: .high,
                isCompleted: false
            ),
            StudyTask(
                title: "Socket Programming Client-Server Lab",
                taskDescription: "Implement multi-threaded TCP chat server in C++ and test packet loss handling.",
                subject: "Computer Networks",
                dueDate: DateHelpers.date(daysFromNow: 3, hour: 14, minute: 0),
                priority: .medium,
                isCompleted: false,
                hasReminder: true,
                reminderDate: DateHelpers.date(daysFromNow: 2, hour: 18, minute: 0)
            ),
            StudyTask(
                title: "Database Normalization (3NF & BCNF)",
                taskDescription: "Decompose university registration schema to eliminate transitive dependencies.",
                subject: "Database Systems",
                dueDate: DateHelpers.date(daysFromNow: -3, hour: 16, minute: 0),
                priority: .medium,
                isCompleted: true,
                completedAt: DateHelpers.date(daysFromNow: -3, hour: 15, minute: 30)
            ),
            StudyTask(
                title: "Agile Sprint Backlog Presentation",
                taskDescription: "Prepare slide deck summarizing user stories, velocity chart, and sprint burndown.",
                subject: "Software Engineering",
                dueDate: DateHelpers.date(daysFromNow: 5, hour: 11, minute: 30),
                priority: .low,
                isCompleted: false
            ),
            StudyTask(
                title: "A* Search Algorithm Complexity Analysis",
                taskDescription: "Submit experimental results comparing admissible heuristics on 8-puzzle problem.",
                subject: "Artificial Intelligence",
                dueDate: DateHelpers.date(daysFromNow: -5, hour: 18, minute: 0),
                priority: .high,
                isCompleted: true,
                completedAt: DateHelpers.date(daysFromNow: -5, hour: 17, minute: 45)
            )
        ]

        for task in tasks {
            context.insert(task)
            NotificationManager.shared.scheduleNotification(for: task)
        }

        // Sample Timetable Sessions
        let classes = [
            ClassSession(
                subject: "Operating Systems",
                teacherName: "Dr. A. Sharma",
                roomNumber: "LH-101",
                weekday: .monday,
                startTime: DateHelpers.time(hour: 9, minute: 0),
                endTime: DateHelpers.time(hour: 10, minute: 30),
                colorHex: "#4F46E5"
            ),
            ClassSession(
                subject: "Mobile Application Dev",
                teacherName: "Prof. K. Rao",
                roomNumber: "CS-Lab 2",
                weekday: .monday,
                startTime: DateHelpers.time(hour: 11, minute: 0),
                endTime: DateHelpers.time(hour: 12, minute: 30),
                colorHex: "#2563EB"
            ),
            ClassSession(
                subject: "Computer Networks",
                teacherName: "Dr. P. Mehta",
                roomNumber: "LH-104",
                weekday: .tuesday,
                startTime: DateHelpers.time(hour: 10, minute: 0),
                endTime: DateHelpers.time(hour: 11, minute: 30),
                colorHex: "#0D9488"
            ),
            ClassSession(
                subject: "Database Systems",
                teacherName: "Prof. S. Gupta",
                roomNumber: "DB-Lab",
                weekday: .wednesday,
                startTime: DateHelpers.time(hour: 9, minute: 30),
                endTime: DateHelpers.time(hour: 11, minute: 0),
                colorHex: "#059669"
            ),
            ClassSession(
                subject: "Software Engineering",
                teacherName: "Prof. R. Verma",
                roomNumber: "LH-203",
                weekday: .thursday,
                startTime: DateHelpers.time(hour: 14, minute: 0),
                endTime: DateHelpers.time(hour: 15, minute: 30),
                colorHex: "#7C3AED"
            ),
            ClassSession(
                subject: "Mobile App Practicum",
                teacherName: "Prof. K. Rao",
                roomNumber: "CS-Lab 1",
                weekday: .friday,
                startTime: DateHelpers.time(hour: 10, minute: 0),
                endTime: DateHelpers.time(hour: 13, minute: 0),
                colorHex: "#DB2777"
            )
        ]

        for session in classes {
            context.insert(session)
        }

        try? context.save()
    }

    /// Deletes all stored tasks and classes from SwiftData.
    static func clearAllData(in context: ModelContext) {
        do {
            let taskFetch = FetchDescriptor<StudyTask>()
            let tasks = try context.fetch(taskFetch)
            for task in tasks {
                NotificationManager.shared.cancelNotification(for: task)
                context.delete(task)
            }

            let classFetch = FetchDescriptor<ClassSession>()
            let classes = try context.fetch(classFetch)
            for session in classes {
                context.delete(session)
            }

            try context.save()
        } catch {
            print("Failed to clear data: \(error.localizedDescription)")
        }
    }
}
