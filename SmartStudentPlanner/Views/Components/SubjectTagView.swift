import SwiftUI

/// Rounded badge displaying the task's subject or category.
struct SubjectTagView: View {
    let subject: String
    var icon: String = "book.closed.fill"

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(subject.isEmpty ? "General" : subject)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .foregroundColor(ColorTheme.primaryIndigo)
        .background(ColorTheme.primaryIndigo.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
