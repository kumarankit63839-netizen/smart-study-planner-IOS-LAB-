import SwiftUI
import SwiftData

/// Detailed view showing full metadata for a study task with editing and deletion controls.
struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var task: StudyTask

    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Status Banner
                statusBanner

                // Main Title & Description
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        SubjectTagView(subject: task.subject)
                        PriorityBadge(priority: task.priority)
                        Spacer()
                    }

                    Text(task.title)
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .modernCardStyle(cornerRadius: 16)

                // Schedule & Deadline Info Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Schedule & Deadline")
                        .font(.headline)

                    Divider()

                    HStack {
                        Label("Due Date", systemImage: "calendar")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(task.formattedDueDate)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Label("Due Time", systemImage: "clock")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(task.formattedDueTime)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Label("Time Remaining", systemImage: "hourglass")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(task.dueCountdown)
                            .fontWeight(.semibold)
                            .foregroundColor(task.isOverdue ? ColorTheme.coralRed : (task.isCompleted ? ColorTheme.mintGreen : ColorTheme.primaryIndigo))
                    }

                    if task.hasReminder, let reminder = task.reminderDate {
                        Divider()
                        HStack {
                            Label("Reminder Alert", systemImage: "bell.badge.fill")
                                .foregroundColor(ColorTheme.amberOrange)
                            Spacer()
                            Text(DateHelpers.formatDate(reminder) + " at " + DateHelpers.formatTime(reminder))
                                .font(.caption.weight(.medium))
                        }
                    }

                    Divider()

                    HStack {
                        Label("Created", systemImage: "doc.text")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                        Text(DateHelpers.formatDate(task.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .modernCardStyle(cornerRadius: 16)

                // Completion Toggle Action Button
                Button(action: toggleCompletion) {
                    HStack(spacing: 8) {
                        Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                            .font(.headline)
                        Text(task.isCompleted ? "Reopen Task as Pending" : "Mark as Completed")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(task.isCompleted ? Color(.secondarySystemBackground) : ColorTheme.mintGreen)
                    .foregroundColor(task.isCompleted ? .primary : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                // Delete Task Button
                Button(role: .destructive, action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                        Text("Delete Task")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(ColorTheme.coralRed)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            TaskFormView(taskToEdit: task)
        }
        .confirmationDialog(
            "Delete Task",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Task", role: .destructive) {
                deleteTask()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(task.title)'? This action cannot be undone.")
        }
    }

    // MARK: - Status Banner View
    @ViewBuilder
    private var statusBanner: some View {
        if task.isCompleted {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(ColorTheme.mintGreen)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Task Completed")
                        .font(.headline)
                        .foregroundColor(ColorTheme.mintGreen)
                    if let completedDate = task.completedAt {
                        Text("Finished on \(DateHelpers.formatDate(completedDate))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
            .background(ColorTheme.mintGreen.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else if task.isOverdue {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(ColorTheme.coralRed)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Task Overdue")
                        .font(.headline)
                        .foregroundColor(ColorTheme.coralRed)
                    Text("This task passed its deadline. Complete it as soon as possible.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(ColorTheme.coralRed.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Actions
    private func toggleCompletion() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            task.isCompleted.toggle()
            if task.isCompleted {
                task.completedAt = Date()
                NotificationManager.shared.cancelNotification(for: task)
            } else {
                task.completedAt = nil
                NotificationManager.shared.scheduleNotification(for: task)
            }
            try? modelContext.save()
        }
    }

    private func deleteTask() {
        NotificationManager.shared.cancelNotification(for: task)
        modelContext.delete(task)
        try? modelContext.save()
        dismiss()
    }
}
