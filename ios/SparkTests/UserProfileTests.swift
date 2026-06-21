import XCTest
@testable import Spark

final class UserProfileTests: XCTestCase {

    func testDecodeValid() throws {
        let json = """
        {"username":"josh","created_at":"2026-01-01T00:00:00.000Z","posts":[]}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.username, "josh")
        XCTAssertEqual(profile.createdAt, "2026-01-01T00:00:00.000Z")
        XCTAssertTrue(profile.posts.isEmpty)
    }

    func testTotalScore() throws {
        let json = """
        {"username":"josh","posts":[
            {"id":"1","title":"A","content":"B","category":"X","score":10},
            {"id":"2","title":"C","content":"D","category":"X","score":20}
        ]}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.totalScore, 30)
    }

    func testTotalScoreEmpty() throws {
        let json = """
        {"username":"josh","posts":[]}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        XCTAssertEqual(profile.totalScore, 0)
    }

    func testDecodeMissingCreatedAt() throws {
        let json = """
        {"username":"josh","posts":[]}
        """.data(using: .utf8)!
        let profile = try JSONDecoder().decode(UserProfile.self, from: json)
        XCTAssertNil(profile.createdAt)
    }
}
