import WidgetKit
import SwiftUI

struct StatsEntry: TimelineEntry {
    let date: Date
    let stats: SparkStats
    let isPlaceholder: Bool

    static var placeholder: StatsEntry {
        StatsEntry(date: .now, stats: .placeholder, isPlaceholder: true)
    }
}

struct StatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatsEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
            return
        }
        let stats = SparkWidgetAPI.cachedStats()
        completion(StatsEntry(date: .now, stats: stats, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<StatsEntry>) -> Void) {
        Task { @Sendable in
            let posts: [WidgetPost]
            do {
                posts = try await SparkWidgetAPI.fetchPosts()
            } catch {
                posts = SparkWidgetAPI.cachedPosts()
            }

            let stats = SparkWidgetAPI.computeStats(from: posts)
            let entry = StatsEntry(date: .now, stats: stats, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
