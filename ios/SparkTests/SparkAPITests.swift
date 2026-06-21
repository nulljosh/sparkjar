import XCTest
@testable import Spark

final class SparkAPITests: XCTestCase {

    func testAPIErrorDescriptions() {
        XCTAssertEqual(APIError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(APIError.badResponse(404).errorDescription, "Server returned 404")
        XCTAssertEqual(APIError.unauthorized.errorDescription, "Session expired. Please sign in again.")
        XCTAssertEqual(APIError.rateLimited.errorDescription, "Too many requests. Try again shortly.")
        XCTAssertEqual(APIError.serverError("oops").errorDescription, "oops")
        XCTAssertEqual(APIError.decodingError("bad").errorDescription, "Decode error: bad")
    }

    func testAPIErrorEquatable() {
        XCTAssertEqual(APIError.unauthorized, APIError.unauthorized)
        XCTAssertEqual(APIError.rateLimited, APIError.rateLimited)
        XCTAssertEqual(APIError.badResponse(404), APIError.badResponse(404))
        XCTAssertNotEqual(APIError.badResponse(404), APIError.badResponse(500))
        XCTAssertNotEqual(APIError.unauthorized, APIError.rateLimited)
        XCTAssertNotEqual(APIError.serverError("a"), APIError.serverError("b"))
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
    }

    func testProtocolConformance() {
        let api: any SparkAPIProtocol = SparkAPI.shared
        XCTAssertNotNil(api)
    }

    func testMockAPIDefaultStates() {
        let mock = MockSparkAPI()
        XCTAssertNil(mock.savedToken)
        XCTAssertFalse(mock.tokenCleared)
        XCTAssertEqual(mock.loginCallCount, 0)
        XCTAssertEqual(mock.voteCallCount, 0)
        XCTAssertEqual(mock.deleteCallCount, 0)
        XCTAssertEqual(mock.fetchCommentsCallCount, 0)
        XCTAssertEqual(mock.addCommentCallCount, 0)
    }

    func testMockTokenSaveLoadClear() {
        let mock = MockSparkAPI()
        XCTAssertNil(mock.loadToken())
        mock.saveToken("test_token")
        XCTAssertEqual(mock.loadToken(), "test_token")
        mock.clearToken()
        XCTAssertNil(mock.loadToken())
        XCTAssertTrue(mock.tokenCleared)
    }
}
