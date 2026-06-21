import Foundation

struct Post: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
    let score: Int
    let author: Author?
    let createdAt: String?
    // LLM enrichment
    let enriched: Bool?
    let enrichmentSpec: String?
    let enrichmentPlan: String?
    let linkedRepo: String?
    let enrichmentRequestedAt: String?

    struct Author: Codable, Hashable {
        let username: String
    }
}
