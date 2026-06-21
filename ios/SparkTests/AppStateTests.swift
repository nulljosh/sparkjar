import XCTest
@testable import Spark

@MainActor
final class AppStateTests: XCTestCase {

    private func makeState(_ configure: (MockSparkAPI) -> Void = { _ in }) -> (AppState, MockSparkAPI) {
        let mock = MockSparkAPI()
        configure(mock)
        return (AppState(api: mock), mock)
    }

    // MARK: - Login

    func testLoginSetsUser() async {
        let (state, mock) = makeState()
        await state.login(username: "josh", password: "pass")

        XCTAssertNotNil(state.user)
        XCTAssertEqual(state.user?.username, "testuser")
        XCTAssertTrue(state.isLoggedIn)
        XCTAssertEqual(mock.loginCallCount, 1)
    }

    func testLoginFailureSetsError() async {
        let (state, _) = makeState { $0.loginResult = .failure(APIError.serverError("Invalid credentials")) }
        await state.login(username: "bad", password: "bad")

        XCTAssertNil(state.user)
        XCTAssertFalse(state.isLoggedIn)
        XCTAssertNotNil(state.error)
    }

    func testLoginClearsOldError() async {
        let (state, _) = makeState()
        state.error = "old error"
        await state.login(username: "josh", password: "pass")

        XCTAssertNil(state.error)
    }

    func testLoginSetsLoadingDuringRequest() async {
        let (state, _) = makeState()
        XCTAssertFalse(state.isLoading)
        await state.login(username: "josh", password: "pass")
        XCTAssertFalse(state.isLoading)
    }

    func testLoginClosesAuthSheet() async {
        let (state, _) = makeState()
        state.showAuth = true
        await state.login(username: "josh", password: "pass")
        XCTAssertFalse(state.showAuth)
    }

    func testLoginLoadsPosts() async {
        let posts = [Post(id: "1", title: "T", content: "C", category: "X", score: 0, author: nil, createdAt: nil)]
        let (state, mock) = makeState { $0.fetchPostsResult = .success(posts) }
        await state.login(username: "josh", password: "pass")

        XCTAssertEqual(state.posts.count, 1)
        XCTAssertEqual(mock.fetchPostsCallCount, 1)
    }

    // MARK: - Register

    func testRegisterSetsUser() async {
        let (state, mock) = makeState()
        await state.register(username: "newuser", email: "a@b.com", password: "pass")

        XCTAssertNotNil(state.user)
        XCTAssertEqual(state.user?.username, "newuser")
        XCTAssertEqual(mock.registerCallCount, 1)
    }

    func testRegisterDuplicateUsernameFails() async {
        let (state, _) = makeState { $0.registerResult = .failure(APIError.serverError("Username already taken")) }
        await state.register(username: "taken", email: nil, password: "pass")

        XCTAssertNil(state.user)
        XCTAssertNotNil(state.error)
        XCTAssertTrue(state.error?.contains("already taken") ?? false)
    }

    func testRegisterWithNilEmail() async {
        let (state, _) = makeState()
        await state.register(username: "user", email: nil, password: "pass")
        XCTAssertNotNil(state.user)
    }

    // MARK: - Logout

    func testLogoutClearsState() async {
        let (state, mock) = makeState()
        await state.login(username: "josh", password: "pass")
        XCTAssertTrue(state.isLoggedIn)

        state.logout()

        XCTAssertNil(state.user)
        XCTAssertFalse(state.isLoggedIn)
        XCTAssertTrue(state.posts.isEmpty)
        XCTAssertTrue(mock.tokenCleared)
    }

    func testLogoutClearsErrorBanner() async {
        let (state, _) = makeState()
        await state.login(username: "josh", password: "pass")
        state.errorBanner = "Something"
        state.logout()
        XCTAssertNil(state.errorBanner)
    }

    // MARK: - Load Posts

    func testLoadPostsPopulatesArray() async {
        let posts = [
            Post(id: "1", title: "A", content: "B", category: "Tech", score: 3, author: nil, createdAt: nil),
            Post(id: "2", title: "C", content: "D", category: "Art", score: 1, author: nil, createdAt: nil)
        ]
        let (state, _) = makeState { $0.fetchPostsResult = .success(posts) }
        await state.loadPosts()

        XCTAssertEqual(state.posts.count, 2)
        XCTAssertEqual(state.posts[0].id, "1")
    }

    func testLoadPostsErrorSetsErrorBanner() async {
        let (state, _) = makeState { $0.fetchPostsResult = .failure(APIError.badResponse(500)) }
        await state.loadPosts()

        XCTAssertNotNil(state.errorBanner)
        XCTAssertTrue(state.posts.isEmpty)
    }

    func testLoadPostsClearsErrorBannerOnSuccess() async {
        let (state, _) = makeState { $0.fetchPostsResult = .success([]) }
        state.errorBanner = "old error"
        await state.loadPosts()

        XCTAssertNil(state.errorBanner)
    }

    func testLoadPostsFetchesCommentCounts() async {
        let posts = [Post(id: "p1", title: "T", content: "C", category: "X", score: 0, author: nil, createdAt: nil)]
        let (state, mock) = makeState {
            $0.fetchPostsResult = .success(posts)
            $0.fetchCommentCountsResult = .success(["p1": 5])
        }
        await state.loadPosts()

        XCTAssertEqual(state.commentCounts["p1"], 5)
        XCTAssertEqual(mock.fetchCommentCountsCallCount, 1)
    }

    func testLoadPostsUnauthorizedDoesNotSetBanner() async {
        let (state, _) = makeState { $0.fetchPostsResult = .failure(APIError.unauthorized) }
        await state.loadPosts()

        XCTAssertNil(state.errorBanner)
    }

    // MARK: - Create Post

    func testCreatePostInsertsAtFront() async throws {
        let (state, _) = makeState {
            $0.fetchPostsResult = .success([
                Post(id: "old", title: "Old", content: "C", category: "X", score: 0, author: nil, createdAt: nil)
            ])
        }
        await state.loadPosts()
        try await state.createPost(title: "New", content: "Body", category: "Tech")

        XCTAssertEqual(state.posts.first?.id, "new1")
        XCTAssertEqual(state.posts.count, 2)
    }

    func testCreatePostFailureThrows() async {
        let (state, _) = makeState { $0.createPostResult = .failure(APIError.unauthorized) }
        do {
            try await state.createPost(title: "T", content: "C", category: "X")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    // MARK: - Delete Post

    func testDeletePostRemovesFromArray() async throws {
        let posts = [
            Post(id: "p1", title: "A", content: "B", category: "Tech", score: 1, author: Post.Author(username: "testuser"), createdAt: nil),
            Post(id: "p2", title: "C", content: "D", category: "Art", score: 2, author: nil, createdAt: nil)
        ]
        let (state, mock) = makeState { $0.fetchPostsResult = .success(posts) }
        await state.loadPosts()

        try await state.deletePost(id: "p1")

        XCTAssertEqual(state.posts.count, 1)
        XCTAssertEqual(state.posts.first?.id, "p2")
        XCTAssertEqual(mock.deleteCallCount, 1)
    }

    func testDeletePostFailureKeepsPosts() async {
        let (state, _) = makeState {
            $0.fetchPostsResult = .success([
                Post(id: "p1", title: "A", content: "B", category: "Tech", score: 1, author: nil, createdAt: nil)
            ])
            $0.deletePostResult = .failure(APIError.badResponse(403))
        }
        await state.loadPosts()

        do {
            try await state.deletePost(id: "p1")
            XCTFail("Expected error")
        } catch {}

        XCTAssertEqual(state.posts.count, 1)
    }

    // MARK: - Dismiss Error

    func testDismissErrorClearsBanner() {
        let (state, _) = makeState()
        state.errorBanner = "Something broke"
        state.dismissError()
        XCTAssertNil(state.errorBanner)
    }

    // MARK: - Sorting

    func testSortedPostsHotMode() async {
        let posts = [
            Post(id: "1", title: "Low", content: "C", category: "X", score: 1, author: nil, createdAt: "2026-01-01T00:00:00.000Z"),
            Post(id: "2", title: "High", content: "C", category: "X", score: 10, author: nil, createdAt: "2026-01-02T00:00:00.000Z")
        ]
        let (state, _) = makeState { $0.fetchPostsResult = .success(posts) }
        await state.loadPosts()
        state.sortMode = .hot

        XCTAssertEqual(state.sortedPosts.first?.id, "2")
    }

    func testSortedPostsNewMode() async {
        let posts = [
            Post(id: "1", title: "Old", content: "C", category: "X", score: 100, author: nil, createdAt: "2026-01-01T00:00:00.000Z"),
            Post(id: "2", title: "New", content: "C", category: "X", score: 1, author: nil, createdAt: "2026-03-01T00:00:00.000Z")
        ]
        let (state, _) = makeState { $0.fetchPostsResult = .success(posts) }
        await state.loadPosts()
        state.sortMode = .new

        XCTAssertEqual(state.sortedPosts.first?.id, "2")
    }

    // MARK: - Comments

    func testLoadComments() async {
        let comments = [
            Comment(id: "c1", postId: "p1", userId: "u1", username: "josh", content: "Nice", createdAt: nil)
        ]
        let (state, mock) = makeState { $0.fetchCommentsResult = .success(comments) }
        await state.loadComments(postId: "p1")

        XCTAssertEqual(state.comments["p1"]?.count, 1)
        XCTAssertEqual(state.commentCounts["p1"], 1)
        XCTAssertEqual(mock.fetchCommentsCallCount, 1)
    }

    func testLoadCommentsError() async {
        let (state, _) = makeState { $0.fetchCommentsResult = .failure(APIError.badResponse(500)) }
        await state.loadComments(postId: "p1")

        XCTAssertNotNil(state.errorBanner)
        XCTAssertNil(state.comments["p1"])
    }

    func testAddComment() async throws {
        let (state, mock) = makeState()
        state.comments["p1"] = []

        try await state.addComment(postId: "p1", content: "Hello")

        XCTAssertEqual(state.comments["p1"]?.count, 1)
        XCTAssertEqual(state.commentCounts["p1"], 1)
        XCTAssertEqual(mock.addCommentCallCount, 1)
        XCTAssertEqual(mock.lastCommentPostId, "p1")
        XCTAssertEqual(mock.lastCommentContent, "Hello")
    }

    func testAddCommentFailureThrows() async {
        let (state, _) = makeState { $0.addCommentResult = .failure(APIError.unauthorized) }
        do {
            try await state.addComment(postId: "p1", content: "X")
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    func testLoadCommentCountsEmpty() async {
        let (state, mock) = makeState()
        await state.loadCommentCounts()
        XCTAssertEqual(mock.fetchCommentCountsCallCount, 0)
    }
}
