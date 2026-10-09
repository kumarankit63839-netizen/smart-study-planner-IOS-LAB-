import SwiftUI

/// Modern card component displaying a single StudyTask.
struct TaskCardView: View {
    let task: StudyTask
    var onToggleCompletion: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Interactive Checkbox Button
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(task.isCompleted ? ColorTheme.mintGreen : (task.isOverdue ? ColorTheme.coralRed : .secondary))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Content Column
            VStack(alignment: .leading, spacing: 6) {
                // Top Meta row: Subject, Priority & Reminder indicator
                HStack(spacing: 6) {
                    SubjectTagView(subject: task.subject)

                    PriorityBadge(priority: task.priority)

                    if task.hasReminder {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10))
                            .foregroundColor(ColorTheme.amberOrange)
                    }

                    Spacer()

                    // Overdue alert badge if applicable
                    if task.isOverdue {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text("Overdue")
                        }
                        .font(.caption2.weight(.bold))
                        .foregroundColor(ColorTheme.coralRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ColorTheme.coralRed.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }

                // Title
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(2)

                // Optional Description preview
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Due Date Footer
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(task.formattedDueDate)
                            .font(.caption)
                    }
                    .foregroundColor(task.isOverdue ? ColorTheme.coralRed : .secondary)

                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Text(task.dueCountdown)
                        .font(.caption.weight(.medium))
                        .foregroundColor(task.isOverdue ? ColorTheme.coralRed : (task.isCompleted ? ColorTheme.mintGreen : .secondary))

                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .modernCardStyle(cornerRadius: 14, elevation: 1)
    }
}
