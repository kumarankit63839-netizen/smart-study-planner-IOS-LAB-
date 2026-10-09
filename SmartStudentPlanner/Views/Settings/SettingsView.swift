import SwiftUI
import SwiftData
import UserNotifications

/// Settings screen for appearance customization, notification permissions, and database operations.
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var notificationManager = NotificationManager.shared

    // App Preferences
    @AppStorage("appAppearance") private var appAppearance: String = "system"
    @State private var showingClearConfirmation = false
    @State private var showingSampleDataAlert = false
    @State private var testNotificationScheduled = false

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Appearance Customization
                Section(
                    header: Text("Appearance"),
                    footer: Text("Choose between System Default, Dark Mode, or Light Mode.")
                ) {
                    Picker("Theme", selection: $appAppearance) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                // Section 2: Notifications & Reminders
                Section(
                    header: Text("Notifications & Reminders"),
                    footer: notificationFooter
                ) {
                    HStack {
                        Label("Permission Status", systemImage: "bell.badge")
                        Spacer()
                        notificationStatusBadge
                    }

                    if notificationManager.authorizationStatus == .notDetermined {
                        Button("Request Notification Permission") {
                            Task {
                                await notificationManager.requestAuthorization()
                            }
                        }
                        .foregroundColor(ColorTheme.primaryIndigo)
                    } else if notificationManager.authorizationStatus == .denied {
                        Button("Open iOS Settings") {
                            openSystemSettings()
                        }
                        .foregroundColor(.blue)
                    }

                    Button(action: triggerTestNotification) {
                        HStack {
                            Label("Send Test Reminder (5s)", systemImage: "paperplane")
                            Spacer()
                            if testNotificationScheduled {
                                Image(systemName: "checkmark")
                                    .foregroundColor(ColorTheme.mintGreen)
                            }
                        }
                    }
                    .foregroundColor(ColorTheme.primaryIndigo)
                }

                // Section 3: Data Management
                Section(
                    header: Text("Sample & Local Data"),
                    footer: Text("Populate demo academic tasks for lab demonstration or reset the local SwiftData storage.")
                ) {
                    Button(action: {
                        SampleDataService.populateSampleData(in: modelContext)
                        showingSampleDataAlert = true
                    }) {
                        Label("Load Sample College Data", systemImage: "square.and.arrow.down")
                            .foregroundColor(ColorTheme.primaryIndigo)
                    }

                    Button(role: .destructive, action: {
                        showingClearConfirmation = true
                    }) {
                        Label("Clear All Application Data", systemImage: "trash")
                            .foregroundColor(ColorTheme.coralRed)
                    }
                }

                // Section 4: About & Academic Lab Information
                Section(header: Text("About Project")) {
                    HStack {
                        Text("Application")
                        Spacer()
                        Text("Smart Student Planner")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Platform")
                        Spacer()
                        Text("iOS 17.0+ (SwiftUI & SwiftData)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Architecture")
                        Spacer()
                        Text("Offline Native MVVM")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Project Scope")
                        Spacer()
                        Text("College iOS Lab Project")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Tasks & Classes", role: .destructive) {
                    SampleDataService.clearAllData(in: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all stored study tasks, assignments, and timetable entries. This action cannot be reversed.")
            }
            .alert("Sample Data Loaded", isPresented: $showingSampleDataAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Standard college courses, assignments, and timetable sessions have been added to your local database.")
            }
            .onAppear {
                Task {
                    await notificationManager.checkAuthorizationStatus()
                }
            }
        }
    }

    // MARK: - Notification Status Badge
    @ViewBuilder
    private var notificationStatusBadge: some View {
        switch notificationManager.authorizationStatus {
        case .authorized:
            Text("Authorized")
                .font(.caption.weight(.semibold))
                .foregroundColor(ColorTheme.mintGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(ColorTheme.mintGreen.opacity(0.12))
                .clipShape(Capsule())
        case .denied:
            Text("Denied")
                .font(.caption.weight(.semibold))
                .foregroundColor(ColorTheme.coralRed)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(ColorTheme.coralRed.opacity(0.12))
                .clipShape(Capsule())
        case .notDetermined:
            Text("Not Determined")
                .font(.caption.weight(.semibold))
                .foregroundColor(ColorTheme.amberOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(ColorTheme.amberOrange.opacity(0.12))
                .clipShape(Capsule())
        default:
            Text("Provisional")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
        }
    }

    private var notificationFooter: some View {
        Text("Local notifications are managed by iOS UserNotifications. Exact delivery timing is handled by system energy and power management algorithms.")
    }

    private func triggerTestNotification() {
        notificationManager.scheduleTestNotification()
        testNotificationScheduled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            testNotificationScheduled = false
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
