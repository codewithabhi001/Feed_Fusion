# 🚀 Feed Fusion — Resilient Multi-Source Feed

A production-grade Flutter application implementing a resilient, unified feed system similar to LinkedIn or Medium. This project demonstrates Clean Architecture, advanced concurrency control, offline-first strategy, and high-performance UI optimization.

---

## 🌟 Key Functional Requirements

- **Unified Feed**: Seamlessly merges data from two distinct APIs (Products & Posts).
- **Infinite Scroll**: Continuous pagination that smartly balances sources.
- **Debounced Search**: Throttled search with cancellation tokens across both sources.
- **Offline Mode**: Two-layer caching (In-memory LRU + Persistent Disk) for seamless offline use.
- **Smart Refresh**: Pull-to-refresh that cancels previous in-flight requests to prevent memory leaks.

---

## 🏆 Bonus Points Achieved

| Feature | Implementation Detail |
|---------|-----------------------|
| 🌐 **Connectivity Listener** | Real-time monitoring with auto-refresh on connectivity restoration. |
| 🔄 **Request Retry** | Graceful error handling with retry buttons and cached fallback. |
| ⏱️ **Performance Logging** | **In-app Performance Viewer**: Real-time tracking of API response & merge times. |
| 🧪 **Unit Testing** | Use Case testing with mock repository support. |
| 🛡️ **Sealed States** | Type-safe state management (`FeedLoading`, `FeedLoaded`, `FeedError`, `FeedCached`). |
| 🚀 **High-FPS native** | Modified `MainActivity.kt` to enable 120Hz refresh rate on supported devices. |

---

## 🛠️ Technical Architecture — Clean Architecture

1.  **Core**: Cross-cutting concerns (network, theme, cache, utils).
2.  **Domain**: Business rules (Entities, Repositories, Use Cases). **Pure Dart**.
3.  **Data**: Implementation details (Models, DataSources, Repo Impl).
4.  **Presentation**: UI logic and widgets (GetX Controllers, Pages, Widgets).

---

## 📦 Tech Stack & Features

- **State Management**: [GetX](https://pub.dev/packages/get) (Sealed state pattern).
- **Networking**: [Dio](https://pub.dev/packages/dio) with custom interceptors & Request Deduplication.
- **Caching**: 
    - **In-memory**: Custom LRU Cache with TTL (Time-To-Live).
    - **Persistent**: SharedPreferences for offline-first support.
- **Fonts & Theme**: Centralized design system using Google Fonts (Inter).
- **UI**: Premium LinkedIn-style design with Shimmer loading and glassmorphism elements.

---

## ⚡ Performance Optimizations

1.  **Request Deduplication**: Prevents calling the same API twice if an identical request is already in-flight.
2.  **Alternating Merge**: Merges lists such that products and posts alternate to keep the feed engaging.
3.  **FPS Boost**: Native Android integration for high refresh rates.
4.  **Optimized Imagery**: Used `cached_network_image` with proper thumbnail sizing.

---

## 🏁 How to Run

1.  Ensure you have Flutter (stable) installed.
2.  Run `flutter pub get`.
3.  Run `flutter run` (Use a physical device for best performance).

---

## 📝 Performance Monitoring (Bonus)
Click the **Analytics Icon (FAB)** on the bottom right of the Feed screen to view real-time performance logs including:
- API Request & Response times.
- Merge operation duration.
- Cache Hit/Miss events.
- Connectivity changes.

---

### Created by Abhishek Kumar
*Technical Assignment — Production-Grade Flutter Development*
