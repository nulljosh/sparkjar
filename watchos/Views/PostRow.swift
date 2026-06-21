import SwiftUI

struct PostRow: View {
    let post: WatchPost

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(post.title)
                    .font(.caption.bold())
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if let author = post.author {
                    Text(author.username)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if post.enriched == true {
                Circle()
                    .fill(Color.sparkBlue)
                    .frame(width: 5, height: 5)
            }

            VStack(spacing: 1) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.sparkBlue)
                Text("\(post.score)")
                    .font(.caption2.monospacedDigit().bold())
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 2)
    }
}
