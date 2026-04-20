# Package: game_engine 🎮

A specialized Flutter package providing high-performance WebView rendering engines for game integration. It provides two core engines: **IHRunner** for in-house/proprietary games and **PLRunner** for 3rd-party provider/live-stream content.

---

## 🚀 Key Features

- **IHRunner (InHouseGameRunner)**: Optimized specialized runner for proprietary/in-house games using the custom host bridge protocol (e.g., Cocos Creator games).
- **PLRunner (ProviderLiveRunner)**: Specialized runner for 3rd-party Live Casino and streaming games, optimized for interactive vendor content.
- **Refactored Performance Architecture**: Leaner and faster `Ctrl` (Controller) logic with unified platform handling.
- **Platform-Abstraction Layer**: Source code organized by `inapp/`, `web_listener/`, and `scripts/` directories for maximum maintainability.
- **Unified Bridge Messaging**: Intelligent communication system via `GameHostEvent` and the consolidated `GameBridgeMixin`.
- **Customizable Runner States**: Modular `IHRunnerState` (idle, loading, loaded, error) for deep integration with UI loading screens.
- **Advanced Resource Management**: Automatically stops media playback (audio/video) and releases resources (WebView dispose) upon widget removal.
- **Auto Injection**: Built-in script injection for `window.FlutterChannel` shim via `IHRunnerScripts`, ensuring 100% compatibility for both new and existing games.

---

## 📦 Installation

Add the package path to your project's `pubspec.yaml`:

```yaml
dependencies:
  game_engine:
    path: packages/game_engine
```

---

## 📖 Usage Guide

### 1. Running a Game with IHRunner

The simplest way to run a game:

```dart
IHRunner(
  gameUrl: 'https://cdn.games.com/my-awesome-game',
  onLoadStart: () => print('Game started loading'),
  onLoadStop: () => print('Game finished loading'),
  onHostMessage: (event) {
    if (event.isCloseWebView) {
      Navigator.pop(context);
    }
  },
)
```

### 2. Advanced: Using IHRunnerCtrl

For programmatic control (reloading, sending messages, evaluating JS):

```dart
// 1. Create a controller
final ctrl = IHRunnerCtrl.inApp();

// 2. Pass to the runner
IHRunner(
  gameUrl: '...',
  controller: ctrl,
);

// 3. Send message TO the game
ctrl.sendMessage(GameHostEvent(type: 'BONUS_REWARD', data: {'amount': 100}));
```

### 3. Monitoring Game States

Use `onStateChanged` to react to loading or error statuses:

```dart
ctrl.onStateChanged.listen((state) {
  if (state == IHRunnerState.error) {
    showErrorDialog('Failed to load game');
  }
});
```

### 4. Running a 3rd-Party Live Game with PLRunner

```dart
PLRunner(
  gameUrl: 'https://vendor-live-stream.com/baccarat',
  onLoadStart: () => print('Loading live game...'),
  onLoadStop: () => print('Game ready!'),
  onError: (error) => print('Provider error: $error'),
  forceLandscapeViewport: true, // Recommended for most live games
)
```

---

## 🔄 Lifecycle & Flow

`game_engine` follows a strictly event-driven architecture:

1. **Initialization**: Widget build triggers bridge script injection via `GameBridgeMixin`.
2. **Loading**: Emits states through `onLoadStart` and `onLoadStop`.
3. **Bridge Ready**: `FlutterChannel` handler is registered and ready for bi-directional traffic.
4. **Web Support**: On Web, `WebMessageListenerMixin` automatically handles `postMessage` traffic and routes it to the controller.
5. **Active State**: Game emits `GameHostEvent`s; Flutter listens and reacts.
6. **Termination**: WebView automatically navigates to `about:blank` and disposes of resources when the widget is popped.

---

## 🛠️ Development & Testing

- **Tests**: Navigate to the package directory and run `flutter test`.
- **Scripts**: All JavaScript shims are located in `lib/src/ih_runner/scripts/`.
- **Formatting**: Always run `dart format .` before committing changes.
- **Analysis**: Maintain zero issues with `flutter analyze`.
- **Documentation**: All public APIs are fully documented using standard `dartdoc` in English.

---
*Developed by Trippy*
