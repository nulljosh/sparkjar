import SwiftUI

private let whatsNewVersion = "2.1.1"
private let whatsNewBullets = [
    "Native iPhone, Mac, and Apple Watch companion apps",
    "AI Idea Bases — generate idea clusters on any topic",
    "Improved feed sorting and category filters",
    "Face ID and Touch ID sign-in",
]

struct WhatsNewSheet: View {
    @AppStorage("whats_new_seen_version") private var seenVersion = ""
    @State private var isPresented = false

    var body: some View {
        Color.clear
            .onAppear { isPresented = seenVersion != whatsNewVersion }
            .sheet(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("What's New in v\(whatsNewVersion)")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(whatsNewBullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(bullet)
                            }
                        }
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)

                    Button {
                        seenVersion = whatsNewVersion
                        isPresented = false
                    } label: {
                        Text("Got it")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.sparkBlue)
                }
                .padding(24)
                .presentationDetents([.medium])
            }
    }
}
