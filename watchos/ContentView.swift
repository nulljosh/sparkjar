import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HotFeedView()
            NewFeedView()
            ComposeView()
        }
        .tabViewStyle(.verticalPage)
    }
}
