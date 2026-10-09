import SwiftUI
import SwiftData

/// Modal form for adding or editing college class timetable sessions.
struct ClassFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allClasses: [ClassSession]

    var sessionToEdit: ClassSession?
    var initialWeekday: Weekday = .monday

    @State private var subject: String = ""
    @State private var teacherName: String = ""
    @State private var roomNumber: String = ""
    @State private var selectedWeekday: Weekday = .monday
    @State private var startTime: Date = DateHelpers.time(hour: 9, minute: 0)
    @State private var endTime: Date = DateHelpers.time(hour: 10, minute: 30)
    @State private var selectedColorHex: String = "#4F46E5"

    var isEditing: Bool {
        sessionToEdit != nil
    }

    /// Validates that end time is chronologically after start time.
    private var isTimeValid: Bool {
        DateHelpers.isTimeOrderValid(start: startTime, end: endTime)
    }

    /// Validates that required text fields are not empty.
    private var isFormValid: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !roomNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isTimeValid
    }

    /// Finds any overlapping class on the selected weekday.
    private var conflictingClass: ClassSession? {
        let sameDayClasses = allClasses.filter { session in
            session.weekday == selectedWeekday &&
            (sessionToEdit == nil || session.id != sessionToEdit?.id)
        }

        return sameDayClasses.first { session in
            DateHelpers.timeRangesOverlap(
                start1: self.startTime,
                end1: self.endTime,
                start2: session.startTime,
                end2: session.endTime
            )
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Subject & Location
                Section(header: Text("Class Information")) {
                    TextField("Subject Name (e.g., Computer Networks)", text: $subject)

                    TextField("Classroom / Room (e.g., LH-101)", text: $roomNumber)

                    TextField("Instructor / Teacher (e.g., Dr. Sharma)", text: $teacherName)
                }

                // Section 2: Day & Timing
                Section(
                    header: Text("Schedule & Timing"),
                    footer: timeFooterView
                ) {
                    Picker("Day of the Week", selection: $selectedWeekday) {
                        ForEach(Weekday.academicWeek) { day in
                            Text(day.fullName).tag(day)
                        }
                    }

                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)

                    if !isTimeValid {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(ColorTheme.coralRed)
                            Text("End time must be later than start time.")
                                .font(.caption.weight(.medium))
                                .foregroundColor(ColorTheme.coralRed)
                        }
                    }
                }

                // Section 3: Conflict Warning Banner
                if let conflict = conflictingClass {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title3)
                                .foregroundColor(ColorTheme.amberOrange)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Timetable Conflict Detected")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(ColorTheme.amberOrange)

                                Text("This slot overlaps with '\(conflict.subject)' (\(conflict.formattedTimeRange)) in \(conflict.roomNumber).")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Section 4: Color Coding
                Section(header: Text("Color Accent")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(ColorTheme.classColors) { option in
                            Button(action: {
                                selectedColorHex = option.hex
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(option.color)
                                        .frame(width: 38, height: 38)

                                    if selectedColorHex == option.hex {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(isEditing ? "Edit Class" : "Add Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveClass()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                populateForm()
            }
        }
    }

    @ViewBuilder
    private var timeFooterView: some View {
        if isTimeValid {
            let duration = max(0, Int(endTime.timeIntervalSince(startTime) / 60))
            let hours = duration / 60
            let minutes = duration % 60
            Text("Class duration: \(hours > 0 ? "\(hours) hr " : "")\(minutes) min")
        }
    }

    private func populateForm() {
        if let session = sessionToEdit {
            subject = session.subject
            teacherName = session.teacherName
            roomNumber = session.roomNumber
            selectedWeekday = session.weekday
            startTime = session.startTime
            endTime = session.endTime
            selectedColorHex = session.colorHex
        } else {
            selectedWeekday = initialWeekday
        }
    }

    private func saveClass() {
        let cleanSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRoom = roomNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTeacher = teacherName.trimmingCharacters(in: .whitespacesAndNewlines)

        if let session = sessionToEdit {
            session.subject = cleanSubject
            session.roomNumber = cleanRoom
            session.teacherName = cleanTeacher
            session.weekday = selectedWeekday
            session.startTime = startTime
            session.endTime = endTime
            session.colorHex = selectedColorHex
        } else {
            let newSession = ClassSession(
                subject: cleanSubject,
                teacherName: cleanTeacher,
                roomNumber: cleanRoom,
                weekday: selectedWeekday,
                startTime: startTime,
                endTime: endTime,
                colorHex: selectedColorHex
            )
            modelContext.insert(newSession)
        }

        try? modelContext.save()
        dismiss()
    }
}
