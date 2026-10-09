import SwiftUI
import SwiftData

/// Root navigation controller providing adaptive layouts:
/// - Bottom TabBar on iPhone (Compact size class)
/// - Modern macOS / iPad NavigationSplitView with Sidebar on Mac Laptops and iPads (Regular size class)
struct MainTabView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("appAppearance") private var appAppearance: String = "system"

    @Query(sort: \StudyTask.dueDate, order: .forward) private var allTasks: [StudyTask]
    @Query(sort: \ClassSession.startTime, order: .forward) private var allClasses: [ClassSession]

    @State private var selectedTab: AppTab = .home
    @State private var showingAddTaskSheet = false
    @State private var showingAddClassSheet = false

    private var pendingCount: Int {
        allTasks.filter { !$0.isCompleted }.count
    }

    private var todayClassesCount: Int {
        allClasses.filter { $0.weekday == Weekday.current }.count
    }

    private var preferredColorScheme: ColorScheme? {
        switch appAppearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // Mac Laptop / iPad Sidebar Navigation
                macLaptopSidebarLayout
            } else {
                // iPhone Standard Bottom TabBar
                compactPhoneTabBarLayout
            }
        }
        .tint(ColorTheme.primaryIndigo)
        .preferredColorScheme(preferredColorScheme)
        .sheet(isPresented: $showingAddTaskSheet) {
            TaskFormView()
        }
        .sheet(isPresented: $showingAddClassSheet) {
            ClassFormView(initialWeekday: Weekday.current)
        }
    }

    // MARK: - Mac Laptop / iPad Split View Layout
    private var macLaptopSidebarLayout: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                // Mac Sidebar Header
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(ColorTheme.primaryIndigo.gradient)
                            .frame(width: 36, height: 36)

                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Student Planner")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.primary)

                        Text("Academic Workspace")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Divider()

                // Sidebar Navigation List
                List(selection: $selectedTab) {
                    Section("Workspace") {
                        NavigationLink(value: AppTab.home) {
                            Label("Home Dashboard", systemImage: AppTab.home.icon)
                        }

                        NavigationLink(value: AppTab.tasks) {
                            HStack {
                                Label("Tasks & Deadlines", systemImage: AppTab.tasks.icon)
                                Spacer()
                                if pendingCount > 0 {
                                    Text("\(pendingCount)")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(ColorTheme.amberOrange.opacity(0.15))
                                        .foregroundColor(ColorTheme.amberOrange)
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        NavigationLink(value: AppTab.timetable) {
                            HStack {
                                Label("Class Timetable", systemImage: AppTab.timetable.icon)
                                Spacer()
                                if todayClassesCount > 0 {
                                    Text("\(todayClassesCount) today")
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(ColorTheme.primaryIndigo.opacity(0.12))
                                        .foregroundColor(ColorTheme.primaryIndigo)
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        NavigationLink(value: AppTab.progress) {
                            Label("Academic Progress", systemImage: AppTab.progress.icon)
                        }
                    }

                    Section("Preferences") {
                        NavigationLink(value: AppTab.settings) {
                            Label("Settings", systemImage: AppTab.settings.icon)
                        }
                    }
                }
                .listStyle(.sidebar)

                Divider()

                // Mac Quick Action Buttons in Sidebar Footer
                VStack(spacing: 8) {
                    Button(action: { showingAddTaskSheet = true }) {
                        Label("New Task (⌘N)", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(ColorTheme.primaryIndigo)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("n", modifiers: [.command])

                    Button(action: { showingAddClassSheet = true }) {
                        Label("New Class", systemImage: "calendar.badge.plus")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(ColorTheme.primaryIndigo.opacity(0.10))
                            .foregroundColor(ColorTheme.primaryIndigo)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 270, max: 320)
        } detail: {
            // Selected Tab Detail Content
            selectedDetailView
        }
    }

    // MARK: - iPhone Bottom TabBar Layout
    private var compactPhoneTabBarLayout: some View {
        TabView(selection: Binding(
            get: { selectedTab.rawValue },
            set: { raw in
                if let tab = AppTab(rawValue: raw) {
                    selectedTab = tab
                }
            }
        )) {
            DashboardView { targetTabRaw in
                if let tab = AppTab(rawValue: targetTabRaw) {
                    selectedTab = tab
                }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.icon)
            }
            .tag(AppTab.home.rawValue)

            TaskListView()
                .tabItem {
                    Label(AppTab.tasks.title, systemImage: AppTab.tasks.icon)
                }
                .tag(AppTab.tasks.rawValue)

            TimetableView()
                .tabItem {
                    Label(AppTab.timetable.title, systemImage: AppTab.timetable.icon)
                }
                .tag(AppTab.timetable.rawValue)

            ProgressTrackerView()
                .tabItem {
                    Label(AppTab.progress.title, systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress.rawValue)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings.rawValue)
        }
    }

    // MARK: - Detail View Router for Mac
    @ViewBuilder
    private var selectedDetailView: some View {
        switch selectedTab {
        case .home:
            DashboardView { targetTabRaw in
                if let tab = AppTab(rawValue: targetTabRaw) {
                    selectedTab = tab
                }
            }
        case .tasks:
            TaskListView()
        case .timetable:
            TimetableView()
        case .progress:
            ProgressTrackerView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - AppTab Definition with Keyboard Shortcuts
enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case tasks = 1
    case timetable = 2
    case progress = 3
    case settings = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .timetable: return "Timetable"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .timetable: return "calendar"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
