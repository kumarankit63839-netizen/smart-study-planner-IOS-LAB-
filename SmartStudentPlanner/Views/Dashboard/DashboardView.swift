import SwiftUI
import SwiftData

/// Main executive home dashboard providing daily progress, upcoming deadlines, and today's timetable.
/// Adaptively responds to iPhone compact screens and Mac laptop wide displays.
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query(sort: \StudyTask.dueDate, order: .forward) private var allTasks: [StudyTask]
    @Query(sort: \ClassSession.startTime, order: .forward) private var allClasses: [ClassSession]

    // Modal Presentation States
    @State private var showingAddTaskSheet = false
    @State private var showingAddClassSheet = false
    @State private var selectedTaskForDetails: StudyTask?

    // Tab Navigation callback (to switch tabs from "See All")
    var onNavigateToTab: ((Int) -> Void)?

    // MARK: - Dynamic Calculated Metrics
    private var totalTasksCount: Int {
        allTasks.count
    }

    private var pendingTasksCount: Int {
        allTasks.filter { !$0.isCompleted }.count
    }

    private var completedTasksCount: Int {
        allTasks.filter { $0.isCompleted }.count
    }

    private var overdueTasksCount: Int {
        allTasks.filter { $0.isOverdue }.count
    }

    private var completionRate: Double {
        guard totalTasksCount > 0 else { return 0.0 }
        return (Double(completedTasksCount) / Double(totalTasksCount)) * 100.0
    }

    /// Next upcoming pending tasks (up to 4)
    private var upcomingTasks: [StudyTask] {
        allTasks.filter { !$0.isCompleted }.prefix(4).map { $0 }
    }

    /// Classes scheduled for today's weekday
    private var todayClasses: [ClassSession] {
        allClasses
            .filter { $0.weekday == Weekday.current }
            .sorted { (c1, c2) -> Bool in
                let cal = Calendar.current
                let m1 = cal.component(.hour, from: c1.startTime) * 60 + cal.component(.minute, from: c1.startTime)
                let m2 = cal.component(.hour, from: c2.startTime) * 60 + cal.component(.minute, from: c2.startTime)
                return m1 < m2
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if horizontalSizeClass == .regular {
                    // Wide Mac Laptop / iPad 2-Column Desktop Grid
                    macLaptopDashboardGrid
                        .padding(24)
                } else {
                    // Standard iPhone Single-Column Stack
                    phoneDashboardStack
                        .padding()
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTaskSheet = true }) {
                        Label("New Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                TaskFormView()
            }
            .sheet(isPresented: $showingAddClassSheet) {
                ClassFormView(initialWeekday: Weekday.current)
            }
            .sheet(item: $selectedTaskForDetails) { task in
                NavigationStack {
                    TaskDetailView(task: task)
                }
            }
        }
    }

    // MARK: - Mac Laptop 2-Column Grid
    private var macLaptopDashboardGrid: some View {
        VStack(spacing: 24) {
            headerSection

            HStack(alignment: .top, spacing: 20) {
                // Left Column: Schedule & Progress
                VStack(spacing: 20) {
                    progressOverviewCard
                    todayClassesSection
                }
                .frame(maxWidth: .infinity)

                // Right Column: Actions, Stats & Urgent Tasks
                VStack(spacing: 20) {
                    quickActionButtons
                    summaryCardsSection
                    upcomingTasksSection
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - iPhone Single-Column Stack
    private var phoneDashboardStack: some View {
        VStack(spacing: 20) {
            headerSection
            progressOverviewCard
            quickActionButtons
            summaryCardsSection
            todayClassesSection
            upcomingTasksSection
        }
    }

    // MARK: - 1. Header Section
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(DateHelpers.formatFullDate(Date()))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(ColorTheme.primaryIndigo)
                    .textCase(.uppercase)

                Text("\(DateHelpers.greetingForCurrentTime()), Scholar!")
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Text("Here is your academic overview for today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Student avatar icon
            ZStack {
                Circle()
                    .fill(ColorTheme.primaryIndigo.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 22))
                    .foregroundColor(ColorTheme.primaryIndigo)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 2. Daily Progress Card
    private var progressOverviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Task Progress")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(totalTasksCount == 0 ? "No active assignments" : "\(completedTasksCount) of \(totalTasksCount) tasks done")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(String(format: "%.0f%%", completionRate))
                    .font(.title2.bold())
                    .foregroundColor(ColorTheme.primaryIndigo)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.primaryIndigo, ColorTheme.skyBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * CGFloat(completionRate / 100.0)), height: 10)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: completionRate)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .modernCardStyle(cornerRadius: 16)
    }

    // MARK: - 3. Quick Action Buttons
    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                showingAddTaskSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("Add Task")
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(ColorTheme.primaryIndigo)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: ColorTheme.primaryIndigo.opacity(0.25), radius: 4, x: 0, y: 2)
            }

            Button(action: {
                showingAddClassSheet = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline)
                    Text("Add Class")
                        .font(.subheadline.bold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(ColorTheme.electricBlue.opacity(0.12))
                .foregroundColor(ColorTheme.electricBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - 4. Summary Metric Cards
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            QuickStatCard(
                title: "Pending Tasks",
                value: "\(pendingTasksCount)",
                subtitle: overdueTasksCount > 0 ? "\(overdueTasksCount) Overdue" : "On Schedule",
                iconName: "clock.badge.exclamationmark",
                accentColor: overdueTasksCount > 0 ? ColorTheme.coralRed : ColorTheme.amberOrange
            )

            QuickStatCard(
                title: "Completed Tasks",
                value: "\(completedTasksCount)",
                subtitle: "Total: \(totalTasksCount)",
                iconName: "checkmark.circle.fill",
                accentColor: ColorTheme.mintGreen
            )
        }
    }

    // MARK: - 5. Today's Classes Section
    private var todayClassesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today's Classes (\(Weekday.current.fullName))", systemImage: "clock")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button("Timetable") {
                    onNavigateToTab?(2) // Switch to Timetable tab
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ColorTheme.primaryIndigo)
            }

            if todayClasses.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundColor(ColorTheme.amberOrange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Classes Scheduled Today")
                            .font(.subheadline.bold())
                        Text("Enjoy your free study day or work on upcoming projects.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .modernCardStyle(cornerRadius: 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(todayClasses) { session in
                        ClassCardView(session: session)
                    }
                }
            }
        }
    }

    // MARK: - 6. Upcoming Tasks Section
    private var upcomingTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Upcoming Tasks", systemImage: "checklist")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Button("See All") {
                    onNavigateToTab?(1) // Switch to Tasks tab
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(ColorTheme.primaryIndigo)
            }

            if upcomingTasks.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundColor(ColorTheme.mintGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("No Pending Deadlines")
                            .font(.subheadline.bold())
                        Text("You are completely caught up! Tap '+ Add Task' to plan ahead.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .modernCardStyle(cornerRadius: 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(upcomingTasks) { task in
                        TaskCardView(task: task) {
                            toggleTaskCompletion(task)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTaskForDetails = task
                        }
                    }
                }
            }
        }
    }

    private func toggleTaskCompletion(_ task: StudyTask) {
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
}
