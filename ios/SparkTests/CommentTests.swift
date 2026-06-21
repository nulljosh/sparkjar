import XCTest
@testable import Spark

final class CommentModelTests: XCTestCase {

    func testDecodeValidComment() throws {
        let json = """
        {
            "id": "c1",
            "post_id": "p1",
            "user_id": "u1",
            "username": "josh",
            "content": "Great idea",
            "created_at": "2026-03-01T12:00:00.000Z"
        }
        """.data(using: .utf8)!

        let comment = try JSONDecoder().decode(Comment.self, from: json)
        XCTAssertEqual(comment.id, "c1")
        XCTAssertEqual(comment.postId, "p1")
        XCTAssertEqual(comment.userId, "u1")
        XCTAssertEqual(comment.username, "josh")
        XCTAssertEqual(comment.content, "Great idea")
        XCTAssertEqual(comment.createdAt, "2026-03-01T12:00:00.000Z")
    }

    func testDecodeCommentMissingOptionalFields() throws {
        let json = """
        {
            "id": "c2",
            "post_id": "p1",
            "user_id": "u1",
            "username": "josh",
            "content": "Short"
        }
        """.data(using: .utf8)!

        let comment = try JSONDecoder().decode(Comment.self, from: json)
        XCTAssertNil(comment.createdAt)
    }

    func testDecodeMissingRequiredFieldThrows() {
        let json = """
        {"id": "c1", "post_id": "p1"}
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Comment.self, from: json))
    }

    func testCommentIdentifiable() throws {
        let json = """
        {"id": "unique", "post_id": "p1", "user_id": "u1", "username": "x", "content": "y"}
        """.data(using: .utf8)!

        let comment = try JSONDecoder().decode(Comment.self, from: json)
        XCTAssertEqual(comment.id, "unique")
    }

    func testCommentHashable() throws {
        let json = """
        {"id": "c1", "post_id": "p1", "user_id": "u1", "username": "x", "content": "y"}
        """.data(using: .utf8)!

        let c1 = try JSONDecoder().decode(Comment.self, from: json)
        let c2 = try JSONDecoder().decode(Comment.self, from: json)
        XCTAssertEqual(c1, c2)
    }

    func testDecodeExtraFieldsIgnored() throws {
        let json = """
        {
            "id": "c1",
            "post_id": "p1",
            "user_id": "u1",
            "username": "x",
            "content": "y",
            "extra_field": "should be ignored"
        }
        """.data(using: .utf8)!

        let comment = try JSONDecoder().decode(Comment.self, from: json)
        XCTAssertEqual(comment.id, "c1")
    }
}
