import Foundation

struct RFSEntry: Codable, Identifiable {
    let slug: String
    let title: String
    let author: String
    let description: String
    let url: String

    var id: String { slug }
}
