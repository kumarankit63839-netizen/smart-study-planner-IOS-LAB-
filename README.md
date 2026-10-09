# Smart Student Planner

**A Modern, Offline-First Native iOS Application Built with Swift, SwiftUI, and SwiftData**

*College iOS Development Lab Project — B.Tech Computer Science and Engineering*

---

## 1. Project Abstract

**Smart Student Planner** is an all-in-one academic productivity application designed to empower college students to manage coursework deadlines, lecture timetables, and academic milestones efficiently. Built from the ground up for **iOS 17+ and macOS** using Apple's latest **SwiftUI**, **SwiftData**, **Swift Charts**, and **UserNotifications** frameworks, the application provides an adaptive universal experience across **iPhone, iPad, and Mac laptops (Mac Catalyst & Mac Designed for iPad)**. It operates entirely offline without requiring external web services, accounts, or recurring subscription fees, ensuring student data privacy and instant responsiveness.

---

## 2. Problem Statement

College students routinely juggle multiple university courses, lab assignments, homework submissions, project deadlines, and fluctuating class timetables. Existing market solutions suffer from several critical shortcomings:
1. **Subscription Paywalls & Clutter**: Commercial productivity apps often lock basic calendar and reminder features behind expensive recurring subscriptions and display distracting advertisements.
2. **Mandatory Internet Connectivity**: Cloud-dependent apps fail to load or notify students when campus Wi-Fi or cellular connections are spotty inside lecture halls or underground labs.
3. **Fragmented Utilities**: Students must switch between separate note apps, calendar apps, and reminder tools, leading to missed assignments, schedule clashes, and elevated academic anxiety.

---

## 3. Objectives

The primary objectives of the **Smart Student Planner** project are:
* To engineer a **unified academic hub** combining deadline tracking, weekly timetable management, and progress analytics.
* To leverage Apple's modern **SwiftData** framework for offline, zero-latency local data persistence on iOS 17+.
* To implement a **smart conflict-detection algorithm** preventing double-booking of lecture hours or laboratory sessions.
* To provide **data-driven academic analytics** using **Swift Charts** to help students visualize their task completion ratios and subject workload distributions.
* To incorporate **system-level local notifications** (`UserNotifications`) alerting students before deadlines even when the app is suspended.
* To adhere strictly to Apple's **Human Interface Guidelines (HIG)**, supporting dynamic Light/Dark mode, accessible typography, and intuitive gestures.

---

## 4. Proposed Solution

The proposed solution is a clean 5-tab native iOS application:
1. **Home Dashboard**: Offers an executive daily overview—personalized greeting, today's date, daily completion ring, today's lecture schedule, and urgent upcoming deadlines.
2. **Tasks & Deadlines**: A comprehensive assignment manager with multi-criteria filtering (All, Pending, Completed, Overdue), keyword search across titles and subjects, priority categorization (Low, Medium, High), and swipe gestures.
3. **Weekly Timetable**: An interactive day-by-day college timetable with automated room/instructor details and a real-time schedule conflict validation engine.
4. **Academic Progress**: Visual charts powered by Apple's `Swift Charts` illustrating task completion proportions, subject-by-subject workload distribution, and motivational study guidance.
5. **Settings & Utilities**: Granular control over application appearance (System, Light, Dark), notification permission management with a live 5-second test trigger, and single-tap demo data seeding for laboratory evaluation.

---

## 5. Software and Hardware Requirements

### Software Requirements
* **Operating System**: macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
* **Integrated Development Environment**: Apple Xcode 15.0 or Xcode 16.0+
* **Language & SDK**: Swift 5.9 / Swift 6.0, iOS 17.0+ / macOS 14.0+ SDK
* **Run Targets**:
  * **Mac Laptop / Desktop**: My Mac (Mac Designed for iPad / Mac Catalyst)
  * **iPhone**: iPhone 15 / iPhone 16 / iPhone SE (3rd Gen) running iOS 17.0+
  * **iPad**: iPad Air / iPad Pro running iPadOS 17.0+

### Hardware Requirements
* **Development & Run Machine**: Apple MacBook (MacBook Air / MacBook Pro M1/M2/M3/M4 or Intel Core i5/i7)
* **Testing Device**: iPhone / iPad with iOS 17.0+ (Optional; Xcode Simulator and Mac destination fully supported)

---

## 6. Technologies and Frameworks Used

| Technology / Framework | Role in Project | Why Selected |
| :--- | :--- | :--- |
| **Swift (5.9+)** | Primary Programming Language | Strong type safety, modern concurrency (`async`/`await`), memory safety with ARC. |
| **SwiftUI** | Declarative User Interface | Reactive state-driven views, automatic Dark Mode support, native animations. |
| **SwiftData** | Persistent Local Database | Successor to Core Data; uses macro-based `@Model` classes with zero boilerplate. |
| **Swift Charts** | Data Visualization | Native Apple charting framework generating performant vector sector and bar charts. |
| **UserNotifications** | Local Notifications | Apple's system-level notification scheduling (`UNCalendarNotificationTrigger`). |
| **SF Symbols 5** | Iconography | High-resolution iconography integrated directly with system typography. |

---

## 7. Application Architecture

Smart Student Planner implements the **Unidirectional Data Flow (UDF) / MVVM** architecture tailored for SwiftUI and SwiftData:

```
┌─────────────────────────────────────────────────────────────┐
│                       SwiftUI Views                         │
│  (DashboardView, TaskListView, TimetableView, ProgressView)  │
└──────────────┬──────────────────────────────▲───────────────┘
               │ User Gestures                │ Reactive Updates
               │ (Add, Edit, Toggle, Delete)  │ (@Query, @Bindable)
               ▼                              │
┌─────────────────────────────────────────────────────────────┐
│                    SwiftData ModelContext                   │
│         (In-Memory Scratchpad & Undo/Redo Management)       │
└──────────────┬──────────────────────────────▲───────────────┘
               │ Saves                        │ Reads
               ▼                              │
┌─────────────────────────────────────────────────────────────┐
│                     Local Disk Store                        │
│             (SQLite Container managed by SwiftData)         │
│          - StudyTask Model       - ClassSession Model       │
└─────────────────────────────────────────────────────────────┘
                               ▲
                               │ Local Trigger
┌──────────────────────────────┴──────────────────────────────┐
│                    NotificationManager                      │
│            (Apple UserNotifications Framework)              │
└─────────────────────────────────────────────────────────────┘
```

* **Views**: Pure declarative SwiftUI views observing data state changes via `@Query` and `@Bindable`.
* **Models**: Pure Swift classes annotated with `@Model` representing persisted business entities.
* **Services**: Isolated singleton services (`NotificationManager`, `SampleDataService`) managing system integration and test fixture initialization.
* **Utilities**: Stateless helper modules (`DateHelpers`, `ColorTheme`) handling conversions, calculations, and visual styles.

---

## 8. Database and Local Storage Design

The app uses **SwiftData** for local storage. Models are defined as follows:

### Entity 1: `StudyTask`
Represents an academic task, assignment, or project.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary key (`@Attribute(.unique)`) |
| `title` | `String` | Title of the assignment (e.g. "Lab 4 Report") |
| `taskDescription` | `String` | Optional notes, guidelines, or instructions |
| `subject` | `String` | Course/subject name (e.g. "Operating Systems") |
| `dueDate` | `Date` | Exact submission deadline |
| `priorityRaw` | `String` | Stored string for `Priority` enum ("Low", "Medium", "High") |
| `isCompleted` | `Bool` | Task completion status flag |
| `completedAt` | `Date?` | Timestamp when the task was finished |
| `createdAt` | `Date` | Timestamp when the task was created |
| `hasReminder` | `Bool` | Whether a local push notification alert is set |
| `reminderDate` | `Date?` | Scheduled trigger timestamp for local notification |

### Entity 2: `ClassSession`
Represents a scheduled lecture, seminar, or laboratory session.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `UUID` | Primary key (`@Attribute(.unique)`) |
| `subject` | `String` | Name of the subject (e.g. "Computer Networks") |
| `teacherName` | `String` | Name of professor or teaching assistant |
| `roomNumber` | `String` | Classroom or laboratory identifier (e.g. "LH-101") |
| `weekdayRaw` | `Int` | Integer matching Apple Calendar weekday (1=Sun, 2=Mon... 7=Sat) |
| `startTime` | `Date` | Class starting time |
| `endTime` | `Date` | Class ending time |
| `colorHex` | `String` | Hexadecimal color string for visual tag |

---

## 9. Conflict Detection Algorithm

To prevent double-booking lectures on the same weekday, `DateHelpers.timeRangesOverlap` compares time intervals solely by hour and minute:

$$\text{Overlap} \iff \max(\text{start}_1, \text{start}_2) < \min(\text{end}_1, \text{end}_2)$$

```swift
static func timeRangesOverlap(start1: Date, end1: Date, start2: Date, end2: Date) -> Bool {
    let cal = Calendar.current
    let s1 = cal.component(.hour, from: start1) * 60 + cal.component(.minute, from: start1)
    let e1 = cal.component(.hour, from: end1) * 60 + cal.component(.minute, from: end1)
    let s2 = cal.component(.hour, from: start2) * 60 + cal.component(.minute, from: start2)
    let e2 = cal.component(.hour, from: end2) * 60 + cal.component(.minute, from: end2)
    
    return max(s1, s2) < min(e1, e2)
}
```

If a user schedules a class that collides with an existing session on that weekday, a real-time warning banner alerts the user and identifies the overlapping class and room.

---

## 10. How to Run the Project in Xcode

### Method A: Direct Project Open (Recommended)
1. Copy or transfer the `studyPlanner` folder to your Mac laptop.
2. Double-click the file named `SmartStudentPlanner.xcodeproj`.
3. In Xcode's top destination menu, you can choose:
   * **Run on your Mac Laptop Directly**: Select **My Mac (Mac Designed for iPad)** or **My Mac (Mac Catalyst)**. The app will launch as a native desktop window on your Mac!
   * **Run in Simulator**: Select **iPhone 15 / 16** or **iPad Pro** running **iOS 17.0+**.
4. Press **⌘R** (Command + R) or click the **Play** button to build and run.

### Method B: Creating a Fresh Xcode Project (Manual Import)
If you prefer creating a new project from scratch:
1. Open Xcode $\rightarrow$ **File** $\rightarrow$ **New** $\rightarrow$ **Project...**
2. Choose **iOS** $\rightarrow$ **App**, and click **Next**.
3. Fill in:
   * **Product Name**: `SmartStudentPlanner`
   * **Team**: None / Personal Team
   * **Organization Identifier**: `com.college`
   * **Interface**: `SwiftUI`
   * **Language**: `Swift`
   * **Storage**: `SwiftData`
4. Replace the template files with the files provided in the `SmartStudentPlanner/` directory:
   * Replace `SmartStudentPlannerApp.swift`
   * Drag-and-drop the `Models/`, `Views/`, `Services/`, and `Utilities/` folders into Xcode. Ensure **"Copy items if needed"** and **"Create groups"** are checked.
5. Press **⌘R** to run.

---

## 11. Code Explanation for B.Tech Viva / Oral Exam

During your college iOS lab evaluation or external viva, use these simple explanations for each core file:

### 1. `SmartStudentPlannerApp.swift`
* **What it is**: The `@main` entry point of the app.
* **Viva Explanation**: *"This file initializes the SwiftData `ModelContainer` for our two database models: `StudyTask` and `ClassSession`. It also checks if the app is launching for the first time, in which case it seeds realistic sample assignments and college classes so the evaluators can immediately test the UI."*

### 2. `StudyTask.swift` & `ClassSession.swift` (`Models/`)
* **What it is**: The data schema models.
* **Viva Explanation**: *"Instead of the older Core Data `.xcdatamodeld` visual files, we use iOS 17's `@Model` macro. Any property in this class is automatically mapped into SQLite tables. We also add computed properties like `isOverdue` and `overlaps` directly on the model for clean business logic."*

### 3. `NotificationManager.swift` (`Services/`)
* **What it is**: Local notification scheduling service.
* **Viva Explanation**: *"This service wraps Apple's `UserNotifications` framework. When a student creates an assignment with a reminder, we create a `UNCalendarNotificationTrigger` using the task's UUID. If the user completes or deletes the task, we immediately call `removePendingNotificationRequests` to cancel unnecessary alerts."*

### 4. `DashboardView.swift` (`Views/Dashboard/`)
* **What it is**: The main home dashboard.
* **Viva Explanation**: *"DashboardView uses `@Query` to reactively fetch tasks and timetable sessions. It computes the completion percentage dynamically, shows today's scheduled classes using `Weekday.current`, and lists urgent upcoming deadlines with instant checkmark completion."*

### 5. `TaskListView.swift` & `TaskFormView.swift` (`Views/Tasks/`)
* **What it is**: Assignment creation, editing, filtering, and deletion.
* **Viva Explanation**: *"We use a segmented picker for All, Pending, Completed, and Overdue tasks, along with `.searchable` for live keyword search. For destructive actions like deleting a task, we use `.confirmationDialog` to prevent accidental loss of data."*

### 6. `TimetableView.swift` & `ClassFormView.swift` (`Views/Timetable/`)
* **What it is**: Weekly timetable scheduler with conflict detection.
* **Viva Explanation**: *"It organizes classes across Monday to Sunday. It enforces input validation so end time must be after start time, and runs an overlap detection algorithm across all classes on the selected weekday to warn the student if two lectures clash."*

### 7. `ProgressTrackerView.swift` (`Views/Progress/`)
* **What it is**: Visual analytics powered by Swift Charts.
* **Viva Explanation**: *"This screen uses Apple's native `Charts` framework. We render a `SectorMark` donut chart for task status breakdown and a `BarMark` chart for subject workload. We also guard against division-by-zero errors when no tasks exist."*

### 8. `SettingsView.swift` (`Views/Settings/`)
* **What it is**: App theme preferences, notification status, and database controls.
* **Viva Explanation**: *"Settings uses `@AppStorage` to toggle Light, Dark, or System mode across the entire app. It also features a 'Send Test Reminder (5s)' button to prove notification capability during lab demos, and allows clearing or resetting sample data."*

---

## 12. Testing Checklist

Use this checklist during your presentation to demonstrate completeness:

- [x] **Launch & First-Run**: App opens smoothly with seeded sample college courses.
- [x] **Add Task**: Tap `+ Add Task`, enter title, course, priority, due date, and save.
- [x] **Complete / Reopen Task**: Tap circular checkmark button; observe smooth strikethrough animation and progress bar increment.
- [x] **Task Filtering**: Switch between All, Pending, Completed, and Overdue tabs.
- [x] **Search**: Type "Operating" or "Lab" in the search bar; verify instantaneous filtering.
- [x] **Edit Task**: Open details, tap Edit, change priority or deadline, and save.
- [x] **Delete Task**: Swipe left or tap Delete; verify confirmation dialog appears before removal.
- [x] **Timetable Weekday Switching**: Tap Mon, Tue, Wed, Thu, Fri, Sat, Sun pills; verify day-specific lectures render.
- [x] **Timetable Clash Detection**: Add a class overlapping an existing class time (e.g., 09:30 AM to 10:15 AM); verify conflict warning appears.
- [x] **Time Order Validation**: Attempt to set an end time earlier than start time; verify inline error and disabled Add button.
- [x] **Progress Analytics**: Open Progress tab; inspect dynamic Donut Sector Chart and Subject Bar Chart.
- [x] **Dark Mode**: Go to Settings $\rightarrow$ Dark Mode; verify all cards, text contrast, and icons adapt smoothly.
- [x] **Notification Test**: In Settings, tap "Send Test Reminder (5s)", lock the simulator/app, and observe native alert pop-up.
- [x] **Data Persistence**: Terminate the app completely and reopen; verify all saved data remains intact.

---

## 13. Limitations

1. **Platform Restriction**: Because iOS applications require the Apple Darwin kernel, macOS, and the Apple LLVM/Clang compiler toolchain, the Xcode project and iOS Simulator can only be executed on an Apple Mac.
2. **Local Notification Exactness**: While local notifications are scheduled at the specified minute, iOS background power management can occasionally adjust delivery by a few seconds.
3. **Single Device Storage**: Data is saved locally using SwiftData SQLite store on the device; synchronization across multiple devices would require Apple CloudKit integration.

---

## 14. Future Enhancements

* **CloudKit Synchronization**: Sync tasks and timetable seamlessly across iPhone, iPad, and Mac via user's private iCloud container.
* **Interactive Home Screen Widgets & Live Activities**: Build `WidgetKit` widgets displaying the next upcoming class and ongoing timer directly on the iOS Lock Screen and Dynamic Island.
* **Calendar Export**: Enable one-tap export of the weekly timetable into the native Apple Calendar app via `EventKit`.
* **Syllabus PDF / OCR Import**: Use VisionKit to scan printed course handouts and automatically generate timetable sessions.

---

## 15. Conclusion

**Smart Student Planner** demonstrates how modern native iOS development paradigms—declarative SwiftUI interfaces, SwiftData persistence, Swift Charts visualization, and system notification services—can be synthesized into an elegant, responsive academic tool. It fulfills all technical, design, and functional requirements for a college iOS development laboratory project.
