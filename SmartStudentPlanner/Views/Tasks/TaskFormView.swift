import SwiftUI
import SwiftData

/// Modal form for creating or editing a study task.
struct TaskFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var taskToEdit: StudyTask?

    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var subject: String = ""
    @State private var dueDate: Date = Date().addingTimeInterval(86400) // Default to tomorrow
    @State private var priority: Priority = .medium
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date().addingTimeInterval(86400 - 3600) // 1 hour before due

    // Common subject recommendations for quick one-tap entry
    private let commonSubjects = ["Computer Science", "Mathematics", "Physics", "Software Eng", "Operating Systems", "Networks"]

    var isEditing: Bool {
        taskToEdit != nil
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Basic Information
                Section(header: Text("Task Details")) {
                    TextField("Task Title (e.g., Lab Report 3)", text: $title)
                        .autocorrectionDisabled(false)

                    TextField("Subject / Course (e.g., Operating Systems)", text: $subject)

                    // Quick Subject Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonSubjects, id: \.self) { item in
                                Button(action: {
                                    subject = item
                                }) {
                                    Text(item)
                                        .font(.caption2.weight(.medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(subject == item ? ColorTheme.primaryIndigo : Color(.secondarySystemBackground))
                                        .foregroundColor(subject == item ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    ZStack(alignment: .topLeading) {
                        if taskDescription.isEmpty {
                            Text("Description or notes (optional)...")
                                .font(.body)
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $taskDescription)
                            .frame(minHeight: 80)
                    }
                }

                // Section 2: Urgency & Scheduling
                Section(header: Text("Priority & Deadline")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            HStack {
                                Image(systemName: p.iconName)
                                Text(p.title)
                            }
                            .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Due Date & Time", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }

                // Section 3: Notification Reminders
                Section(
                    header: Text("Reminders"),
                    footer: Text("Local notifications will alert you when this assignment or task is due.")
                ) {
                    Toggle("Enable Reminder Alert", isOn: $hasReminder.animation())
                        .tint(ColorTheme.primaryIndigo)

                    if hasReminder {
                        DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])

                        if reminderDate < Date() {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(ColorTheme.amberOrange)
                                Text("Reminder date is in the past. Select a future time.")
                                    .font(.caption)
                                    .foregroundColor(ColorTheme.amberOrange)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add Task") {
                        saveTask()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                populateFormIfEditing()
            }
        }
    }

    private func populateFormIfEditing() {
        if let task = taskToEdit {
            title = task.title
            taskDescription = task.taskDescription
            subject = task.subject
            dueDate = task.dueDate
            priority = task.priority
            hasReminder = task.hasReminder
            reminderDate = task.reminderDate ?? task.dueDate.addingTimeInterval(-3600)
        }
    }

    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "General" : subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = taskDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let task = taskToEdit {
            task.title = trimmedTitle
            task.taskDescription = trimmedDescription
            task.subject = trimmedSubject
            task.dueDate = dueDate
            task.priority = priority
            task.hasReminder = hasReminder
            task.reminderDate = hasReminder ? reminderDate : nil

            NotificationManager.shared.rescheduleNotification(for: task)
        } else {
            let newTask = StudyTask(
                title: trimmedTitle,
                taskDescription: trimmedDescription,
                subject: trimmedSubject,
                dueDate: dueDate,
                priority: priority,
                isCompleted: false,
                hasReminder: hasReminder,
                reminderDate: hasReminder ? reminderDate : nil
            )

            modelContext.insert(newTask)
            NotificationManager.shared.scheduleNotification(for: newTask)
        }

        try? modelContext.save()
        dismiss()
    }
}
