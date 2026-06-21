import XCTest
@testable import Spark

final class PostTests: XCTestCase {

    func testDecodeValidPost() throws {
        let json = """
        {"id":"abc","title":"Test","content":"Body","category":"Tech","score":5,"author":{"username":"josh"},"createdAt":"2026-03-01T12:00:00.000Z"}
        """.data(using: .utf8)!
        let post = try JSONDecoder().decode(Post.self, from: json)
        XCTAssertEqual(post.id, "abc")
        XCTAssertEqual(post.title, "Test")
        XCTAssertEqual(post.score, 5)
        XCTAssertEqual(post.author?.username, "josh")
    }

    func testDecodePostMissingOptionals() throws {
        let json = """
        {"id":"abc","title":"T","content":"C","category":"X","score":0}
        """.data(using: .utf8)!
        let post = try JSONDecoder().decode(Post.self, from: json)
        XCTAssertNil(post.author)
        XCTAssertNil(post.createdAt)
    }

    func testDecodeMalformedThrows() {
        let json = """
        {"id":"abc","title":123}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Post.self, from: json))
    }

    func testPostIdentifiable() throws {
        let json = """
        {"id":"u1","title":"T","content":"C","category":"X","score":0}
        """.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(Post.self, from: json).id, "u1")
    }

    func testPostHashable() throws {
        let json = """
        {"id":"u1","title":"T","content":"C","category":"X","score":0}
        """.data(using: .utf8)!
        let a = try JSONDecoder().decode(Post.self, from: json)
        let b = try JSONDecoder().decode(Post.self, from: json)
        XCTAssertEqual(a, b)
    }

    func testDecodeExtraFieldsIgnored() throws {
        let json = """
        {"id":"u1","title":"T","content":"C","category":"X","score":0,"extra":"ignored"}
        """.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(Post.self, from: json).id, "u1")
    }

    func testDecodeNegativeScore() throws {
        let json = """
        {"id":"u1","title":"T","content":"C","category":"X","score":-5}
        """.data(using: .utf8)!
        XCTAssertEqual(try JSONDecoder().decode(Post.self, from: json).score, -5)
    }

    func testDecodeEmptyStrings() throws {
        let json = """
        {"id":"","title":"","content":"","category":"","score":0}
        """.data(using: .utf8)!
        let post = try JSONDecoder().decode(Post.self, from: json)
        XCTAssertEqual(post.id, "")
    }
}
