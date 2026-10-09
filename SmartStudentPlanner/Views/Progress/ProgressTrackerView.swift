import SwiftUI
import SwiftData
import Charts

/// Dedicated academic progress and productivity analytics dashboard using Swift Charts.
struct ProgressTrackerView: View {
    @Query private var tasks: [StudyTask]

    // MARK: - Computed Analytics
    private var totalTasks: Int {
        tasks.count
    }

    private var completedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }

    private var pendingTasks: Int {
        tasks.filter { !$0.isCompleted && !$0.isOverdue }.count
    }

    private var overdueTasks: Int {
        tasks.filter { $0.isOverdue }.count
    }

    /// Safe completion percentage preventing division by zero.
    private var completionRate: Double {
        guard totalTasks > 0 else { return 0.0 }
        return (Double(completedTasks) / Double(totalTasks)) * 100.0
    }

    /// Task status slice data for charts.
    private var statusChartData: [StatusSlice] {
        [
            StatusSlice(status: "Completed", count: completedTasks, color: ColorTheme.mintGreen),
            StatusSlice(status: "Pending", count: pendingTasks, color: ColorTheme.primaryIndigo),
            StatusSlice(status: "Overdue", count: overdueTasks, color: ColorTheme.coralRed)
        ].filter { $0.count > 0 }
    }

    /// Grouped subject summary data.
    private var subjectSummaries: [SubjectSummary] {
        let grouped = Dictionary(grouping: tasks) { $0.subject }
        return grouped.map { (subject, subjectTasks) in
            let total = subjectTasks.count
            let completed = subjectTasks.filter { $0.isCompleted }.count
            let pending = total - completed
            let overdue = subjectTasks.filter { $0.isOverdue }.count
            return SubjectSummary(
                subject: subject,
                total: total,
                completed: completed,
                pending: pending,
                overdue: overdue
            )
        }.sorted { $0.total > $1.total }
    }

    /// Priority breakdown data.
    private var priorityChartData: [PrioritySlice] {
        [
            PrioritySlice(priority: "High", count: tasks.filter { $0.priority == .high }.count, color: Color.red),
            PrioritySlice(priority: "Medium", count: tasks.filter { $0.priority == .medium }.count, color: Color.orange),
            PrioritySlice(priority: "Low", count: tasks.filter { $0.priority == .low }.count, color: Color.blue)
        ].filter { $0.count > 0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if totalTasks == 0 {
                    EmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "No Progress Data Yet",
                        description: "Add tasks and complete assignments to unlock productivity charts and subject insights."
                    )
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 20) {
                        // Section 1: Overview Percentage & Key Metric Cards
                        metricCardsGrid

                        // Section 2: Task Status Swift Chart
                        statusChartCard

                        // Section 3: Subject Breakdown Swift Chart
                        subjectChartCard

                        // Section 4: Subject Performance List
                        subjectPerformanceSection

                        // Section 5: Motivational Feedback
                        motivationalCard
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Academic Progress")
        }
    }

    // MARK: - Metric Cards Grid
    private var metricCardsGrid: some View {
        VStack(spacing: 12) {
            // Big Circular Progress Header
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 10)
                        .frame(width: 90, height: 90)

                    Circle()
                        .trim(from: 0, to: CGFloat(min(completionRate / 100.0, 1.0)))
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.primaryIndigo, ColorTheme.mintGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 90, height: 90)
                        .animation(.easeOut(duration: 0.8), value: completionRate)

                    Text(String(format: "%.0f%%", completionRate))
                        .font(.title3.bold())
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Completion")
                        .font(.headline)

                    Text("\(completedTasks) of \(totalTasks) tasks completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(completionRate >= 80 ? "Superb consistency! 🎓" : (completionRate >= 50 ? "Steady progress, keep going! 📚" : "Time to focus on pending tasks! ✏️"))
                        .font(.caption.weight(.medium))
                        .foregroundColor(ColorTheme.primaryIndigo)
                        .padding(.top, 2)
                }

                Spacer()
            }
            .padding(16)
            .modernCardStyle(cornerRadius: 16)

            // 4 Mini Stat Blocks
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                miniStatCard(title: "Total Tasks", count: totalTasks, icon: "tray.full.fill", color: ColorTheme.primaryIndigo)
                miniStatCard(title: "Completed", count: completedTasks, icon: "checkmark.circle.fill", color: ColorTheme.mintGreen)
                miniStatCard(title: "Pending", count: pendingTasks, icon: "clock.fill", color: ColorTheme.amberOrange)
                miniStatCard(title: "Overdue", count: overdueTasks, icon: "exclamationmark.triangle.fill", color: ColorTheme.coralRed)
            }
        }
    }

    private func miniStatCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
                Spacer()
                Text("\(count)")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .modernCardStyle(cornerRadius: 14)
    }

    // MARK: - Status Chart Card (Swift Charts)
    private var statusChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Task Status Breakdown", systemImage: "chart.pie.fill")
                    .font(.headline)
                Spacer()
            }

            Chart(statusChartData) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.55),
                    angularInset: 2.0
                )
                .cornerRadius(4)
                .foregroundStyle(item.color)
            }
            .frame(height: 180)

            // Legend
            HStack(spacing: 16) {
                Spacer()
                ForEach(statusChartData) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text("\(item.status): \(item.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .modernCardStyle(cornerRadius: 16)
    }

    // MARK: - Subject Chart Card (Swift Charts BarMark)
    private var subjectChartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Workload by Subject", systemImage: "chart.bar.fill")
                    .font(.headline)
                Spacer()
            }

            Chart(subjectSummaries) { item in
                BarMark(
                    x: .value("Subject", item.subject),
                    y: .value("Tasks", item.total)
                )
                .foregroundStyle(ColorTheme.primaryIndigo.gradient)
                .cornerRadius(6)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4))
            }
        }
        .padding(16)
        .modernCardStyle(cornerRadius: 16)
    }

    // MARK: - Subject Performance Section
    private var subjectPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subject Performance")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(subjectSummaries) { summary in
                    let rate = summary.total > 0 ? (Double(summary.completed) / Double(summary.total)) : 0.0

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(summary.subject)
                                .font(.subheadline.weight(.semibold))

                            Spacer()

                            Text("\(summary.completed)/\(summary.total) completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(rate == 1.0 ? ColorTheme.mintGreen : ColorTheme.primaryIndigo)
                                    .frame(width: max(0, geo.size.width * CGFloat(rate)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(12)
                    .modernCardStyle(cornerRadius: 12)
                }
            }
        }
    }

    // MARK: - Motivational Card
    private var motivationalCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.title2)
                .foregroundColor(ColorTheme.amberOrange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Study Tip")
                    .font(.caption.bold())
                    .foregroundColor(ColorTheme.amberOrange)
                Text(randomStudyTip())
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(ColorTheme.amberOrange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func randomStudyTip() -> String {
        if overdueTasks > 0 {
            return "Clear your overdue tasks first to reduce academic stress and regain momentum!"
        } else if completionRate > 75 {
            return "Great discipline! Review your upcoming class notes ahead of time for top grades."
        } else {
            return "Try using the Pomodoro technique (25 min study, 5 min break) for tough topics."
        }
    }
}

// MARK: - Data Models for Charts
struct StatusSlice: Identifiable {
    var id: String { status }
    let status: String
    let count: Int
    let color: Color
}

struct SubjectSummary: Identifiable {
    var id: String { subject }
    let subject: String
    let total: Int
    let completed: Int
    let pending: Int
    let overdue: Int
}

struct PrioritySlice: Identifiable {
    var id: String { priority }
    let priority: String
    let count: Int
    let color: Color
}
