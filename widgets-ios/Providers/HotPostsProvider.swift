import WidgetKit
import SwiftUI

struct HotPostsEntry: TimelineEntry {
    let date: Date
    let posts: [SparkPost]
    let isPlaceholder: Bool

    static var placeholder: HotPostsEntry {
        HotPostsEntry(
            date: .now,
            posts: [
                SparkPost(id: "1", title: "Add dark mode to everything", content: "", category: "Feature", votes: 42, author: "josh", createdAt: "2026-03-25T10:00:00Z"),
                SparkPost(id: "2", title: "Better onboarding flow", content: "", category: "UX", votes: 28, author: "alex", createdAt: "2026-03-25T09:00:00Z"),
                SparkPost(id: "3", title: "API rate limiting", content: "", category: "Backend", votes: 15, author: "sam", createdAt: "2026-03-25T08:00:00Z"),
            ],
            isPlaceholder: true
        )
    }
}

struct HotPostsProvider: TimelineProvider {
    func placeholder(in context: Context) -> HotPostsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (HotPostsEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        let cached = WidgetAPI.cachedHotPosts()
        completion(HotPostsEntry(date: .now, posts: cached, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HotPostsEntry>) -> Void) {
        Task {
            let posts: [SparkPost]
            do {
                posts = try await WidgetAPI.fetchHotPosts()
            } catch {
                posts = WidgetAPI.cachedHotPosts()
            }

            let entry = HotPostsEntry(date: .now, posts: posts, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
