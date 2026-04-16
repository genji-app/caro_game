import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:co_caro_flame/s88/core/services/config/sb_config.dart';

/// Central manager for app audio playback.
///
/// - **Singleton**: single [AudioPlayer] instance, lazy-initialized for performance.
/// - **Repeat**: [repeat] controls loop vs stop after complete.
/// - **Lifecycle**: call [onAppLifecycleChanged] when app goes to background/closed
///   to stop playback (wire from root widget with [WidgetsBindingObserver]).
class AudioManager {
  AudioManager._();

  static String get AUDIO_URL => SbConfig.cdnAudio;

  static AudioManager? _instance;

  /// Singleton instance. Prefer this over constructing to reuse one player.
  static AudioManager get instance => _instance ??= AudioManager._();

  AudioPlayer? _player;

  AudioPlayer get _playerOrCreate {
    _player ??= AudioPlayer();
    _player!.setVolume(1.0);
    return _player!;
  }

  bool _repeat = false;

  /// When true, playback loops; when false, stops after completion.
  bool get repeat => _repeat;

  set repeat(bool value) {
    if (_repeat == value) return;
    _repeat = value;
    _applyReleaseMode();
  }

  void _applyReleaseMode() {
    _player?.setReleaseMode(_repeat ? ReleaseMode.loop : ReleaseMode.stop);
  }

  /// Plays from a [Source] (e.g. [AssetSource], [UrlSource]).
  /// Sets [repeat] before starting. Reuses same player instance.
  Future<void> play(Source source, {bool? repeat}) async {
    if (repeat != null) this.repeat = repeat;
    _applyReleaseMode();
    await _playerOrCreate.play(source);
  }

  /// Convenience: play asset by path (e.g. 'sounds/click.mp3').
  Future<void> playAsset(String path, {bool? repeat = false}) async {
    await play(AssetSource(path), repeat: repeat);
  }

  /// Convenience: play from URL.
  Future<void> playUrl(String url, {bool? repeat = false}) async {
    await play(UrlSource(url), repeat: repeat);
  }

  Future<void> stop() async {
    await _player?.stop();
  }

  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> resume() async {
    await _player?.resume();
  }

  /// Call when app lifecycle changes. Stops audio when app is minimized or closed.
  /// Wire from root: [WidgetsBinding.instance.addObserver] and dispatch here.
  void onAppLifecycleChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        stop();
        break;
      case AppLifecycleState.resumed:
        // No auto-resume; user can start again if desired.
        break;
    }
  }

  /// Optional: release native resources. Singleton stays; player recreated on next [play].
  Future<void> release() async {
    await _player?.release();
    _player = null;
  }
}
