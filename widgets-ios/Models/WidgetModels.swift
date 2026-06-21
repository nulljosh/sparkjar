import Foundation

struct SparkPost: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let category: String
    let votes: Int
    let author: String
    let createdAt: String
    let enriched: Bool?

    var relativeTime: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: createdAt) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: createdAt) else { return "" }
            return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .now)
        }
        return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .now)
    }
}

struct SparkStats {
    let totalPosts: Int
    let yourPosts: Int
}
