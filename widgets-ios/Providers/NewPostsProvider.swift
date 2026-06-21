import WidgetKit
import SwiftUI

struct NewPostsEntry: TimelineEntry {
    let date: Date
    let posts: [SparkPost]
    let isPlaceholder: Bool

    static var placeholder: NewPostsEntry {
        NewPostsEntry(
            date: .now,
            posts: [
                SparkPost(id: "1", title: "WebSocket support for live updates", content: "", category: "Feature", votes: 5, author: "josh", createdAt: "2026-03-25T12:00:00Z"),
                SparkPost(id: "2", title: "Mobile app gesture nav", content: "", category: "UX", votes: 3, author: "alex", createdAt: "2026-03-25T11:30:00Z"),
                SparkPost(id: "3", title: "Export posts as markdown", content: "", category: "Feature", votes: 1, author: "sam", createdAt: "2026-03-25T11:00:00Z"),
            ],
            isPlaceholder: true
        )
    }
}

struct NewPostsProvider: TimelineProvider {
    func placeholder(in context: Context) -> NewPostsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (NewPostsEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        let cached = WidgetAPI.cachedNewPosts()
        completion(NewPostsEntry(date: .now, posts: cached, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewPostsEntry>) -> Void) {
        Task {
            let posts: [SparkPost]
            do {
                posts = try await WidgetAPI.fetchNewPosts()
            } catch {
                posts = WidgetAPI.cachedNewPosts()
            }

            let entry = NewPostsEntry(date: .now, posts: posts, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
