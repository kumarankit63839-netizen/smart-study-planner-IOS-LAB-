import SwiftUI

/// A reusable, elegant empty state view adhering to Apple HIG.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(ColorTheme.primaryIndigo.opacity(0.8))
                .padding(.bottom, 4)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.subheadline.bold())
                        Text(buttonTitle)
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(ColorTheme.primaryIndigo)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}
