import SwiftUI

/// Compact priority pill badge indicating task urgency.
struct PriorityBadge: View {
    let priority: Priority
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.iconName)
                .font(.system(size: compact ? 9 : 11, weight: .bold))

            if !compact {
                Text(priority.title)
                    .font(.caption2.weight(.semibold))
            }
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 2 : 4)
        .foregroundColor(priority.color)
        .background(priority.backgroundColor)
        .clipShape(Capsule())
    }
}
