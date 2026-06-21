import Foundation

struct Post: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
    let score: Int
    let author: Author?
    let createdAt: String?
    let enriched: Bool?
    let enrichmentSpec: String?
    let enrichmentPlan: String?
    let linkedRepo: String?

    struct Author: Codable, Hashable {
        let username: String
    }
}

struct IdeaBase: Codable, Identifiable {
    let id: String
    let topic: String
    let description: String?
    let postIds: [String]?
    let pending: Bool?
    let createdBy: String?
    let createdAt: String?
}
