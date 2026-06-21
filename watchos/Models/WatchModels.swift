import Foundation

struct WatchPost: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
    let score: Int
    let author: Author?
    let createdAt: String?
    let enriched: Bool?

    struct Author: Codable, Hashable {
        let username: String
    }
}

struct PostsResponse: Codable {
    let posts: [WatchPost]
    let mode: String?
}

struct AuthResponse: Codable {
    let token: String
    let username: String
    let userId: String
}
