import SwiftUI
import SwiftData

/// Full-featured weekly college timetable schedule organizer.
struct TimetableView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClassSession.startTime, order: .forward) private var allClasses: [ClassSession]

    @State private var selectedWeekday: Weekday = Weekday.current
    @State private var showingAddSheet = false
    @State private var sessionToEdit: ClassSession?
    @State private var sessionToDelete: ClassSession?
    @State private var showingDeleteConfirmation = false

    /// Filters and sorts classes for the selected day of the week.
    private var classesForSelectedDay: [ClassSession] {
        allClasses
            .filter { $0.weekday == selectedWeekday }
            .sorted { (c1, c2) -> Bool in
                let cal = Calendar.current
                let m1 = cal.component(.hour, from: c1.startTime) * 60 + cal.component(.minute, from: c1.startTime)
                let m2 = cal.component(.hour, from: c2.startTime) * 60 + cal.component(.minute, from: c2.startTime)
                return m1 < m2
            }
    }

    /// Checks if any overlapping classes exist on the currently viewed day.
    private var hasConflictOnCurrentDay: Bool {
        let classes = classesForSelectedDay
        guard classes.count > 1 else { return false }

        for i in 0..<classes.count {
            for j in (i + 1)..<classes.count {
                if DateHelpers.timeRangesOverlap(
                    start1: classes[i].startTime,
                    end1: classes[i].endTime,
                    start2: classes[j].startTime,
                    end2: classes[j].endTime
                ) {
                    return true
                }
            }
        }
        return false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Day Selector Horizontal Bar
                daySelectorBar
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemGroupedBackground))

                // Schedule Conflict Alert Banner (if any)
                if hasConflictOnCurrentDay {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(ColorTheme.amberOrange)
                        Text("Class schedule conflict detected on \(selectedWeekday.fullName)!")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(ColorTheme.amberOrange)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(ColorTheme.amberOrange.opacity(0.12))
                }

                // Class Session List / Empty State
                if classesForSelectedDay.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        title: "No Classes on \(selectedWeekday.fullName)",
                        description: "You have no college lectures or lab sessions scheduled for this day.",
                        buttonTitle: "Add Class",
                        action: { showingAddSheet = true }
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(classesForSelectedDay) { session in
                            ClassCardView(session: session)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    sessionToEdit = session
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        sessionToEdit = session
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(ColorTheme.primaryIndigo)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        sessionToDelete = session
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
            .navigationTitle("Class Timetable")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                ClassFormView(initialWeekday: selectedWeekday)
            }
            .sheet(item: $sessionToEdit) { session in
                ClassFormView(sessionToEdit: session)
            }
            .confirmationDialog(
                "Delete Class Session",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Class", role: .destructive) {
                    if let session = sessionToDelete {
                        delete(session: session)
                    }
                }
                Button("Cancel", role: .cancel) {
                    sessionToDelete = nil
                }
            } message: {
                if let session = sessionToDelete {
                    Text("Are you sure you want to delete '\(session.subject)'? This action cannot be undone.")
                }
            }
        }
    }

    // MARK: - Weekday Selector Bar
    private var daySelectorBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Weekday.academicWeek) { day in
                    let isSelected = day == selectedWeekday
                    let isToday = day == Weekday.current

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedWeekday = day
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(day.shortName)
                                .font(.caption.weight(isSelected ? .bold : .medium))

                            // Dot indicator if this day is today
                            if isToday {
                                Circle()
                                    .fill(isSelected ? .white : ColorTheme.primaryIndigo)
                                    .frame(width: 4, height: 4)
                            } else {
                                Spacer()
                                    .frame(height: 4)
                            }
                        }
                        .frame(width: 44, height: 48)
                        .background(isSelected ? ColorTheme.primaryIndigo : Color.clear)
                        .foregroundColor(isSelected ? .white : (isToday ? ColorTheme.primaryIndigo : .secondary))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Deletion Action
    private func delete(session: ClassSession) {
        withAnimation {
            modelContext.delete(session)
            try? modelContext.save()
            sessionToDelete = nil
        }
    }
}
