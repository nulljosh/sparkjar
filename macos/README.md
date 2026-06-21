![Spark macOS](../icon.svg)
# Spark macOS
![version](https://img.shields.io/badge/version-v1.0.0-blue)

Native macOS companion app for the Spark idea-sharing platform. Built with SwiftUI, targeting macOS 14+.

## Features

- Browse, search, and filter posts by category
- Sort by Hot or New
- Upvote and downvote posts with optimistic updates
- Create posts with title, content, and category
- User profile with own post management
- JWT authentication stored in Keychain
- Keyboard shortcuts: Cmd-N (new post), Cmd-R (refresh)
- Dark/light mode follows system

## Build

```bash
cd macos
xcodegen generate
open SparkMac.xcodeproj
```

## Architecture

```
SparkApp (WindowGroup + Commands)
  -> ContentView (NavigationSplitView sidebar)
       -> FeedView (NavigationSplitView list/detail)
       -> CreateView (Form)
       -> ProfileView (List)
  -> AuthSheet (modal)
  -> AppState (@Observable, shared via .environment)
  -> SparkAPI (URLSession, Keychain token storage)
```

## License

MIT 2026, Joshua Trommel
