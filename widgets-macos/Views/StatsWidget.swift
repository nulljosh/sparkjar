import WidgetKit
import SwiftUI

struct StatsWidget: Widget {
    let kind = "SparkStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            StatsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Spark Stats")
        .description("Total posts, votes, and active users at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StatsWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: StatsEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: - Small

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.sparkBlue)
                Text("Stats")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            statBlock(
                icon: "doc.text.fill",
                label: "Posts",
                value: "\(entry.stats.totalPosts)",
                color: Color.sparkBlue
            )

            statBlock(
                icon: "arrow.up.circle.fill",
                label: "Votes",
                value: "\(entry.stats.totalVotes)",
                color: Color.sparkOrange
            )

            statBlock(
                icon: "person.2.fill",
                label: "Users",
                value: "\(entry.stats.activeUsers)",
                color: Color.sparkGreen
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }

    private func statBlock(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
                .frame(width: 14)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold).monospacedDigit())
        }
    }

    // MARK: - Medium

    private var mediumView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.sparkBlue)
                Text("Spark Stats")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 8)

            HStack(spacing: 0) {
                statCard(
                    icon: "doc.text.fill",
                    label: "Ideas",
                    value: "\(entry.stats.totalPosts)",
                    color: Color.sparkBlue
                )

                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)

                statCard(
                    icon: "arrow.up.circle.fill",
                    label: "Votes",
                    value: "\(entry.stats.totalVotes)",
                    color: Color.sparkOrange
                )

                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)

                statCard(
                    icon: "person.2.fill",
                    label: "Users",
                    value: "\(entry.stats.activeUsers)",
                    color: Color.sparkGreen
                )
            }

            Spacer(minLength: 4)
        }
        .redacted(reason: entry.isPlaceholder ? .placeholder : [])
    }

    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
