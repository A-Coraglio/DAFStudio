import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Lets every scrollable be dragged with the mouse (and stylus/trackpad),
/// not just touch — otherwise the home carousels can't be swiped on
/// desktop/web builds.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}
