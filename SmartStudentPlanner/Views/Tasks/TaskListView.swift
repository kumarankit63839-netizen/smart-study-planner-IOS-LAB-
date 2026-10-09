import SwiftUI
import SwiftData

/// Dedicated screen for comprehensive task management, sorting, searching, and filtering.
struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StudyTask.dueDate, order: .forward) private var allTasks: [StudyTask]

    // Filtering & Sorting State
    @State private var selectedFilter: TaskFilter = .all
    @State private var sortOption: TaskSortOption = .dueDateAscending
    @State private var searchText: String = ""

    // Sheet and Alert presentation
    @State private var showingAddTaskSheet = false
    @State private var taskToDelete: StudyTask?
    @State private var showingDeleteConfirmation = false

    enum TaskFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
        case overdue = "Overdue"

        var id: String { rawValue }
    }

    enum TaskSortOption: String, CaseIterable, Identifiable {
        case dueDateAscending = "Due Date (Earliest)"
        case dueDateDescending = "Due Date (Latest)"
        case priorityDescending = "Priority (High to Low)"
        case subjectAscending = "Subject (A-Z)"

        var id: String { rawValue }
    }

    // Filtered and Sorted Task Array
    private var filteredTasks: [StudyTask] {
        var result = allTasks

        // 1. Search Query
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.subject.lowercased().contains(query) ||
                $0.taskDescription.lowercased().contains(query)
            }
        }

        // 2. Filter Status
        switch selectedFilter {
        case .all:
            break
        case .pending:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .overdue:
            result = result.filter { $0.isOverdue }
        }

        // 3. Sorting
        switch sortOption {
        case .dueDateAscending:
            result.sort { $0.dueDate < $1.dueDate }
        case .dueDateDescending:
            result.sort { $0.dueDate > $1.dueDate }
        case .priorityDescending:
            result.sort { $0.priority.sortWeight > $1.priority.sortWeight }
        case .subjectAscending:
            result.sort { $0.subject.localizedCaseInsensitiveCompare($1.subject) == .orderedAscending }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segmented Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

                // Task List / Empty State
                if filteredTasks.isEmpty {
                    emptyStateForCurrentFilter
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskCardView(task: task) {
                                    toggleCompletion(for: task)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .leading) {
                                Button {
                                    toggleCompletion(for: task)
                                } label: {
                                    Label(
                                        task.isCompleted ? "Reopen" : "Done",
                                        systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                    )
                                }
                                .tint(task.isCompleted ? .orange : ColorTheme.mintGreen)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    taskToDelete = task
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Tasks & Assignments")
            .searchable(text: $searchText, prompt: "Search title or subject...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(TaskSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddTaskSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                TaskFormView()
            }
            .confirmationDialog(
                "Delete Task",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Task", role: .destructive) {
                    if let task = taskToDelete {
                        delete(task: task)
                    }
                }
                Button("Cancel", role: .cancel) {
                    taskToDelete = nil
                }
            } message: {
                if let task = taskToDelete {
                    Text("Are you sure you want to delete '\(task.title)'? This action cannot be undone.")
                }
            }
        }
    }

    // MARK: - Filter Empty States
    @ViewBuilder
    private var emptyStateForCurrentFilter: some View {
        switch selectedFilter {
        case .all:
            if !searchText.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Matching Tasks",
                    description: "No tasks found matching '\(searchText)'."
                )
            } else {
                EmptyStateView(
                    icon: "checklist",
                    title: "No Tasks Added Yet",
                    description: "Stay ahead of your coursework by adding your assignments, readings, and lab deadlines.",
                    buttonTitle: "Add First Task",
                    action: { showingAddTaskSheet = true }
                )
            }
        case .pending:
            EmptyStateView(
                icon: "checkmark.circle",
                title: "All Caught Up!",
                description: "You have no pending tasks. Great job staying organized!",
                buttonTitle: "Add New Task",
                action: { showingAddTaskSheet = true }
            )
        case .completed:
            EmptyStateView(
                icon: "clock.arrow.circlepath",
                title: "No Completed Tasks",
                description: "Finished assignments and tasks will appear here once marked as done."
            )
        case .overdue:
            EmptyStateView(
                icon: "sparkles",
                title: "Zero Overdue Tasks",
                description: "Awesome! You do not have any overdue submissions or assignments."
            )
        }
    }

    // MARK: - Helpers
    private func toggleCompletion(for task: StudyTask) {
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

    private func delete(task: StudyTask) {
        withAnimation {
            NotificationManager.shared.cancelNotification(for: task)
            modelContext.delete(task)
            try? modelContext.save()
            taskToDelete = nil
        }
    }
}
