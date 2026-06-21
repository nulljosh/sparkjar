import SwiftUI

// MARK: - Brand Colors

extension Color {
    /// Spark primary blue — matches the app's sparkBlue
    static let sparkBlue = Color(red: 0/255, green: 113/255, blue: 227/255)

    /// Spark accent orange — for flame/hot indicators
    static let sparkOrange = Color(red: 255/255, green: 149/255, blue: 0/255)

    /// Spark green — for positive stats
    static let sparkGreen = Color(red: 48/255, green: 209/255, blue: 88/255)
}

// MARK: - Category Pill

struct SparkCategoryPill: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .semibold))
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.sparkBlue.opacity(0.12), in: Capsule())
            .foregroundStyle(Color.sparkBlue)
    }
}
