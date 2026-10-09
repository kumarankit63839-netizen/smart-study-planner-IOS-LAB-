import SwiftUI

/// Compact dashboard statistic summary card.
struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: iconName)
                        .foregroundColor(accentColor)
                        .font(.system(size: 16, weight: .semibold))
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(accentColor)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modernCardStyle(cornerRadius: 16)
    }
}
