import SwiftUI

struct IdeaBaseView: View {
    @Environment(AppState.self) private var appState
    @State private var topic = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var message: String?
    @State private var ideaBases: [IdeaBase] = []

    var body: some View {
        NavigationStack {
            Form {
                if appState.isLoggedIn {
                    Section("Generate Ideas on a Topic") {
                        TextField("Topic", text: $topic)
                        TextField("Context (optional)", text: $description, axis: .vertical)
                            .lineLimit(2...4)
                        Button(action: submit) {
                            if isSubmitting {
                                ProgressView().frame(maxWidth: .infinity)
                            } else {
                                Text("Queue Generation")
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(topic.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
                        if let msg = message {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Recent Idea Bases") {
                    if ideaBases.isEmpty {
                        Text("No idea bases yet")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(ideaBases) { ib in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ib.topic)
                                    .font(.subheadline.weight(.medium))
                                HStack {
                                    Text(ib.pending == true ? "Pending" : "Done")
                                        .font(.caption2)
                                        .foregroundStyle(ib.pending == true ? .orange : .green)
                                    Spacer()
                                    Text("\(ib.postIds?.count ?? 0) ideas")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Idea Base")
            .task {
                ideaBases = (try? await appState.api.fetchIdeaBases()) ?? []
            }
        }
    }

    private func submit() {
        isSubmitting = true
        message = nil
        Task {
            do {
                _ = try await appState.api.createIdeaBase(
                    topic: topic,
                    description: description.isEmpty ? nil : description
                )
                message = "Queued. Ideas will appear in feed within 5 minutes."
                topic = ""
                description = ""
                ideaBases = (try? await appState.api.fetchIdeaBases()) ?? []
            } catch {
                message = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
