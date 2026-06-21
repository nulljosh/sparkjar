import SwiftUI

@main
struct SparkApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .frame(minWidth: 700, minHeight: 500)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 900, height: 650)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Post") {
                    NotificationCenter.default.post(name: .navigateToCreate, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button("Refresh Feed") {
                    NotificationCenter.default.post(name: .refreshFeed, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let navigateToCreate = Notification.Name("navigateToCreate")
    static let refreshFeed = Notification.Name("refreshFeed")
}
