/// Stub implementation for non-web platforms.
///
/// All getters return `false` since browser detection is irrelevant
/// on native platforms (Android/iOS/desktop).
library;

/// Whether the current browser is Safari on an iPhone/iPod.
///
/// Always `false` on non-web platforms.
bool get isIOSSafariWeb => false;

/// Always `false` on non-web platforms.
bool get isWebAndroidBrowser => false;

/// Always `false` on non-web platforms.
bool get isWebIOSBrowser => false;
