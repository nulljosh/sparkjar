import SwiftUI

struct HotFeedView: View {
    @State private var posts: [WatchPost] = []
    @State private var isLoading = true

    private var hotPosts: [WatchPost] {
        posts.sorted { $0.score > $1.score }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.sparkBlue)
                        Text("HOT")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    } else if hotPosts.isEmpty {
                        VStack(spacing: 4) {
                            Image(systemName: "lightbulb")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                            Text("No posts yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    } else {
                        ForEach(hotPosts.prefix(8)) { post in
                            NavigationLink(value: post) {
                                PostRow(post: post)
                            }
                            .buttonStyle(.plain)

                            if post.id != hotPosts.prefix(8).last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationDestination(for: WatchPost.self) { post in
                PostDetailView(post: post)
            }
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        if let cached = WatchAPI.shared.cachedPosts() {
            posts = cached
            isLoading = false
        }
        do {
            posts = try await WatchAPI.shared.fetchPosts()
        } catch {}
        isLoading = false
    }
}
