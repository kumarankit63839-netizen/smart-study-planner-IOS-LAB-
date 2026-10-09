import SwiftUI

/// Card representation of a scheduled timetable class.
struct ClassCardView: View {
    let session: ClassSession

    /// Determines if this session is happening right now.
    private var isCurrentlyActive: Bool {
        guard session.weekday == Weekday.current else { return false }
        let now = Date()
        let cal = Calendar.current
        let currentMinutes = cal.component(.hour, from: now) * 60 + cal.component(.minute, from: now)
        let startMinutes = cal.component(.hour, from: session.startTime) * 60 + cal.component(.minute, from: session.startTime)
        let endMinutes = cal.component(.hour, from: session.endTime) * 60 + cal.component(.minute, from: session.endTime)

        return currentMinutes >= startMinutes && currentMinutes <= endMinutes
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left color accent bar
            Rectangle()
                .fill(session.displayColor)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 8) {
                // Top Row: Time Range, Duration & Ongoing Badge
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(session.formattedTimeRange)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundColor(session.displayColor)

                    Text("(\(session.formattedDuration))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if isCurrentlyActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(ColorTheme.mintGreen)
                                .frame(width: 7, height: 7)
                            Text("NOW")
                                .font(.caption2.bold())
                                .foregroundColor(ColorTheme.mintGreen)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ColorTheme.mintGreen.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }

                // Subject Name
                Text(session.subject)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)

                // Meta Info: Room and Teacher
                HStack(spacing: 14) {
                    if !session.roomNumber.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 11))
                            Text(session.roomNumber)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.secondary)
                    }

                    if !session.teacherName.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 11))
                            Text(session.teacherName)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(14)
        }
        .modernCardStyle(cornerRadius: 14, elevation: 1)
    }
}
