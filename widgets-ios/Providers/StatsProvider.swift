import WidgetKit
import SwiftUI

struct StatsEntry: TimelineEntry {
    let date: Date
    let stats: SparkStats
    let isPlaceholder: Bool

    static var placeholder: StatsEntry {
        StatsEntry(
            date: .now,
            stats: SparkStats(totalPosts: 127, yourPosts: 14),
            isPlaceholder: true
        )
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
        let cached = WidgetAPI.cachedStats()
        completion(StatsEntry(date: .now, stats: cached, isPlaceholder: false))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> Void) {
        Task {
            let stats: SparkStats
            do {
                stats = try await WidgetAPI.fetchStats()
            } catch {
                stats = WidgetAPI.cachedStats()
            }

            let entry = StatsEntry(date: .now, stats: stats, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}
