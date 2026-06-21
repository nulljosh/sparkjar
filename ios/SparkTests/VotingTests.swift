import XCTest
@testable import Spark

@MainActor
final class VotingTests: XCTestCase {

    private func stateWithPosts(_ posts: [Post], mock: MockSparkAPI = MockSparkAPI()) -> (AppState, MockSparkAPI) {
        mock.fetchPostsResult = .success(posts)
        let state = AppState(api: mock)
        return (state, mock)
    }

    private let samplePosts = [
        Post(id: "p1", title: "T", content: "C", category: "X", score: 5, author: nil, createdAt: nil)
    ]

    func testVoteCallsAPI() async {
        let (state, mock) = stateWithPosts(samplePosts)
        await state.loadPosts()

        await state.vote(postId: "p1", type: "up")

        XCTAssertEqual(mock.voteCallCount, 1)
        XCTAssertEqual(mock.lastVotePostId, "p1")
        XCTAssertEqual(mock.lastVoteType, "up")
    }

    func testVoteRevertsOnFailure() async {
        let mock = MockSparkAPI()
        mock.voteResult = .failure(APIError.badResponse(500))
        let (state, _) = stateWithPosts(samplePosts, mock: mock)
        await state.loadPosts()

        await state.vote(postId: "p1", type: "up")

        XCTAssertEqual(state.posts.first?.score, 5)
        XCTAssertNotNil(state.errorBanner)
    }

    func testVoteRevertsOnUnauthorized() async {
        let mock = MockSparkAPI()
        mock.voteResult = .failure(APIError.unauthorized)
        let (state, _) = stateWithPosts(samplePosts, mock: mock)
        await state.loadPosts()

        await state.vote(postId: "p1", type: "up")

        XCTAssertEqual(state.posts.first?.score, 5)
    }

    func testDownvoteDecrementsScore() async {
        let mock = MockSparkAPI()
        let (state, _) = stateWithPosts(samplePosts, mock: mock)
        await state.loadPosts()

        await state.vote(postId: "p1", type: "down")

        XCTAssertEqual(mock.voteCallCount, 1)
        XCTAssertEqual(mock.lastVoteType, "down")
    }

    func testVoteOnNonexistentPostDoesNotCrash() async {
        let (state, mock) = stateWithPosts(samplePosts)
        await state.loadPosts()

        await state.vote(postId: "nonexistent", type: "up")

        XCTAssertEqual(mock.voteCallCount, 1)
    }

    func testVoteOnMultipleDifferentPosts() async {
        let posts = [
            Post(id: "p1", title: "A", content: "C", category: "X", score: 3, author: nil, createdAt: nil),
            Post(id: "p2", title: "B", content: "C", category: "X", score: 7, author: nil, createdAt: nil)
        ]
        let (state, mock) = stateWithPosts(posts)
        await state.loadPosts()

        await state.vote(postId: "p1", type: "up")
        await state.vote(postId: "p2", type: "down")

        XCTAssertEqual(mock.voteCallCount, 2)
    }
}
