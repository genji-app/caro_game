import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

/// GlobalKey to control the mobile SliderDrawer programmatically.
/// Usage: ref.read(sliderDrawerKeyProvider).currentState?.toggle()
final sliderDrawerKeyProvider = Provider<GlobalKey<SliderDrawerState>>((ref) {
  return GlobalKey<SliderDrawerState>();
});
