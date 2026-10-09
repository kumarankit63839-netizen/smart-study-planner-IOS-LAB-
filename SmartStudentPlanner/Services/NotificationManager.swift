import Foundation
import UserNotifications
import Combine

/// Central manager for user notifications utilizing Apple's UserNotifications framework.
/// Runs on the MainActor for SwiftUI state binding.
@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var lastErrorMessage: String?

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    /// Checks current notification permission status with the iOS system.
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }

    /// Explicitly requests notification authorization from the user.
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            self.lastErrorMessage = error.localizedDescription
            await checkAuthorizationStatus()
            return false
        }
    }

    /// Schedules a local notification for a study task based on its reminder date or due date.
    func scheduleNotification(for task: StudyTask) {
        // Only schedule if reminders are requested and the task is pending
        guard task.hasReminder, !task.isCompleted else {
            cancelNotification(for: task)
            return
        }

        // Determine target notification fire date (reminder date takes priority over due date)
        let fireDate = task.reminderDate ?? task.dueDate

        // Do not schedule notifications in the past
        guard fireDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder: \(task.title)"
        content.subtitle = task.subject
        content.body = "Due \(task.formattedDueDate) at \(task.formattedDueTime). Priority: \(task.priority.title)"
        content.sound = .default
        content.badge = 1

        let triggerDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    /// Cancels scheduled notification requests for the given task.
    func cancelNotification(for task: StudyTask) {
        let identifier = task.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    /// Reschedules or updates a task's notification (e.g. after edit).
    func rescheduleNotification(for task: StudyTask) {
        cancelNotification(for: task)
        scheduleNotification(for: task)
    }

    /// Dispatches a quick demo/test notification after 5 seconds for verification during lab demonstration.
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Smart Student Planner Test"
        content.body = "Notifications are working properly! Your study reminders will appear like this."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "SmartStudentPlanner_TestNotification_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
