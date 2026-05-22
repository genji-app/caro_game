import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Mixin responsible for locking dimensions (Size Stabilization) of an Iframe
/// during the initial web game initialization phase.
///
/// Many game engines (especially casino games) read viewport dimensions
/// during JS/CSS initialization and DON'T re-read on resize until fully
/// initialized. If the iframe container resizes mid-init (e.g. the user
/// rotates the device in DevTools), the game captures wrong dimensions
/// and its CSS layout breaks permanently.
///
/// Strategy:
///   1. Lock the iframe to fixed pixel dimensions immediately after creation.
///   2. Unlock when the iframe `load` event fires + a 2-second buffer for
///      post-load JS initialization.
///   3. Safety net: unlock after 15 seconds regardless, in case `load` never
///      fires (common with cross-origin / streaming game URLs).
mixin IFrameDimensionLockMixin<T extends StatefulWidget> on State<T> {
  /// Safety-net timer that unlocks after [_kMaxStabilizationDuration].
  Timer? _maxStabilizationTimer;

  /// Post-load delay timer: waits a bit after `load` event before unlocking.
  Timer? _postLoadUnlockTimer;

  /// Whether the iframe dimensions are currently locked.
  bool _isDimensionLocked = false;

  /// Maximum time to keep the lock regardless of load event.
  static const _kMaxStabilizationDuration = Duration(seconds: 15);

  /// Extra delay after iframe `load` event before unlocking, to let the
  /// game's JavaScript finish initializing (canvas, event handlers, etc.).
  static const _kPostLoadBuffer = Duration(seconds: 2);

  /// Cleans up all stabilization timers.
  void removeDimensionLockTimers() {
    _maxStabilizationTimer?.cancel();
    _postLoadUnlockTimer?.cancel();
  }

  /// Locks the iframe to its current rendered pixel dimensions.
  ///
  /// Called shortly after the iframe is inserted into the DOM, BEFORE `src`
  /// is set, so the game's initialization always sees stable dimensions.
  // ignore: unused_element
  void lockIframeDimensions(web.HTMLIFrameElement? iframe) {
    if (iframe == null || !mounted) return;

    final rect = iframe.getBoundingClientRect();
    final w = rect.width.toInt();
    final h = rect.height.toInt();

    if (w <= 0 || h <= 0) {
      web.console.warn(
        'Iframe has zero dimensions ($w x $h), skipping stabilization.'.toJS,
      );
      return;
    }

    iframe.style.width = '${w}px';
    iframe.style.height = '${h}px';
    _isDimensionLocked = true;
    web.console.log('Iframe dimensions locked: ${w}x$h'.toJS);

    // Safety net: unlock after max duration even if `load` never fires.
    _maxStabilizationTimer = Timer(
      _kMaxStabilizationDuration,
      () => unlockIframeDimensions(iframe),
    );
  }

  /// Called when the iframe `load` event fires. Schedules an unlock after
  /// [_kPostLoadBuffer] to give the game's JS time to finish initializing.
  // ignore: unused_element
  void schedulePostLoadUnlock(web.HTMLIFrameElement? iframe) {
    if (!_isDimensionLocked) return;

    // Cancel any previous post-load timer (in case of multiple load events
    // from internal redirects).
    _postLoadUnlockTimer?.cancel();

    _postLoadUnlockTimer = Timer(
      _kPostLoadBuffer,
      () => unlockIframeDimensions(iframe),
    );
    web.console.log(
      'Iframe load detected, scheduling unlock in ${_kPostLoadBuffer.inSeconds}s.'.toJS,
    );
  }

  /// Switches the iframe back to responsive `100%` / `100%` sizing.
  void unlockIframeDimensions(web.HTMLIFrameElement? iframe) {
    _maxStabilizationTimer?.cancel();
    _postLoadUnlockTimer?.cancel();
    if (iframe == null || !mounted || !_isDimensionLocked) return;

    iframe.style.width = '100%';
    iframe.style.height = '100%';
    _isDimensionLocked = false;
    web.console.log('Iframe dimensions unlocked to responsive.'.toJS);
  }
}
