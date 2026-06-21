import Foundation

struct UserProfile: Codable {
    let username: String
    let createdAt: String?
    let posts: [Post]

    enum CodingKeys: String, CodingKey {
        case username
        case createdAt = "created_at"
        case posts
    }

    var totalScore: Int {
        posts.reduce(0) { $0 + $1.score }
    }
}
