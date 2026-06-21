import WidgetKit
import SwiftUI

@main
struct SparkWidgets: WidgetBundle {
    var body: some Widget {
        HotPostsWidget()
        NewPostsWidget()
        StatsWidget()
    }
}
