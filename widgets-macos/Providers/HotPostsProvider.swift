import WidgetKit
import SwiftUI

struct HotPostsEntry: TimelineEntry {
    let date: Date
    let posts: [WidgetPost]
    let isPlaceholder: Bool

    static var placeholder: HotPostsEntry {
        HotPostsEntry(
            date: .now,
            posts: [
                WidgetPost(id: "1", title: "AI-powered code review for small teams", content: "What if we built a lightweight code reviewer...", category: "Technology", score: 47, author: .init(username: "josh"), createdAt: nil),
                WidgetPost(id: "2", title: "Neighborhood tool-sharing app", content: "Like a library but for power tools...", category: "Business", score: 34, author: .init(username: "alex"), createdAt: nil),
                WidgetPost(id: "3", title: "Open-source Mars habitat designs", content: "Modular 3D-printable habitat components...", category: "Science", score: 29, author: .init(username: "nova"), createdAt: nil),
                WidgetPost(id: "4", title: "Composable music production studio", content: "Browser-based DAW with plugin marketplace...", category: "Design", score: 22, author: .init(username: "kai"), createdAt: nil),
                WidgetPost(id: "5", title: "Micro-grant platform for students", content: "Crowdfund small research grants...", category: "Business", score: 18, author: .init(username: "sam"), createdAt: nil),
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
        let cached = SparkWidgetAPI.hotPosts(from: SparkWidgetAPI.cachedPosts())
        completion(HotPostsEntry(date: .now, posts: cached, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<HotPostsEntry>) -> Void) {
        Task { @Sendable in
            let posts: [WidgetPost]
            do {
                posts = try await SparkWidgetAPI.fetchPosts()
            } catch {
                posts = SparkWidgetAPI.cachedPosts()
            }

            let hot = SparkWidgetAPI.hotPosts(from: posts)
            let entry = HotPostsEntry(date: .now, posts: hot, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
