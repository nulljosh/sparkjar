import Foundation

struct IdeaBase: Codable, Identifiable {
    let id: String
    let topic: String
    let description: String?
    let postIds: [String]?
    let pending: Bool?
    let createdBy: String?
    let createdAt: String?
}
