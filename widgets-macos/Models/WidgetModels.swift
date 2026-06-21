import Foundation

// MARK: - Widget Data Models

struct WidgetPost: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let category: String
    let score: Int
    let author: Author?
    let createdAt: String?
    let enriched: Bool?

    struct Author: Codable {
        let username: String
    }
}

struct SparkStats: Codable {
    let totalPosts: Int
    let totalVotes: Int
    let activeUsers: Int

    static let empty = SparkStats(totalPosts: 0, totalVotes: 0, activeUsers: 0)

    static let placeholder = SparkStats(totalPosts: 142, totalVotes: 1837, activeUsers: 28)
}

// MARK: - API Response

private struct PostsResponse: Codable {
    let posts: [WidgetPost]
    let mode: String?
}
