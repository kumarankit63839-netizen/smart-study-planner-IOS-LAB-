import SwiftUI
import SwiftData

/// Application entry point configuring SwiftData container and root view hierarchy.
/// Supports both iOS (iPhone & iPad) and macOS (Mac laptops & desktops).
@main
struct SmartStudentPlannerApp: App {
    /// SwiftData shared container configured for StudyTask and ClassSession schema.
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                StudyTask.self,
                ClassSession.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    checkAndSeedInitialData()
                }
                #if os(macOS)
                .frame(minWidth: 920, minHeight: 620)
                #endif
        }
        .modelContainer(container)
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }
        #endif
    }

    /// Automatically seeds helpful initial college tasks on the very first launch.
    @MainActor
    private func checkAndSeedInitialData() {
        let hasLaunchedBeforeKey = "hasLaunchedSmartStudentPlannerBefore"
        if !UserDefaults.standard.bool(forKey: hasLaunchedBeforeKey) {
            let context = container.mainContext
            SampleDataService.populateSampleData(in: context)
            UserDefaults.standard.set(true, forKey: hasLaunchedBeforeKey)
        }
    }
}
