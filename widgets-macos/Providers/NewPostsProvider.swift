import WidgetKit
import SwiftUI

struct NewPostsEntry: TimelineEntry {
    let date: Date
    let posts: [WidgetPost]
    let isPlaceholder: Bool

    static var placeholder: NewPostsEntry {
        NewPostsEntry(
            date: .now,
            posts: [
                WidgetPost(id: "1", title: "Real-time collaborative whiteboard", content: "Infinite canvas with multiplayer...", category: "Design", score: 5, author: .init(username: "luna"), createdAt: "2026-03-25T20:00:00Z"),
                WidgetPost(id: "2", title: "Decentralized recipe book", content: "Fork and remix recipes like code...", category: "Other", score: 3, author: .init(username: "max"), createdAt: "2026-03-25T19:30:00Z"),
                WidgetPost(id: "3", title: "Campus energy dashboard", content: "Track and gamify energy savings...", category: "Science", score: 8, author: .init(username: "rio"), createdAt: "2026-03-25T18:45:00Z"),
                WidgetPost(id: "4", title: "AI debate partner", content: "Practice argumentation with AI...", category: "Technology", score: 2, author: .init(username: "zoe"), createdAt: "2026-03-25T18:00:00Z"),
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
        let cached = SparkWidgetAPI.newPosts(from: SparkWidgetAPI.cachedPosts())
        completion(NewPostsEntry(date: .now, posts: cached, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NewPostsEntry>) -> Void) {
        Task { @Sendable in
            let posts: [WidgetPost]
            do {
                posts = try await SparkWidgetAPI.fetchPosts()
            } catch {
                posts = SparkWidgetAPI.cachedPosts()
            }

            let newest = SparkWidgetAPI.newPosts(from: posts)
            let entry = NewPostsEntry(date: .now, posts: newest, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
