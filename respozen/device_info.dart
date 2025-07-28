import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:respozen/src/responsive_config.dart';

enum DeviceType { mobile, tablet, desktop, largeDesktop }
enum DeviceOS { android, ios, web, windows, macos, linux }


class DeviceInfo {
  final DeviceType type;
  final DeviceOS os;
  final Orientation orientation;
  final double width;
  final double height;
  final double pixelRatio;
  final bool isWeb;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;


  DeviceInfo._({
    required this.type,
    required this.os,
    required this.orientation,
    required this.width,
    required this.height,
    required this.pixelRatio,
    required this.isWeb,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  static DeviceInfo fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;
    final pixelRatio = mediaQuery.devicePixelRatio;

    final isWeb = kIsWeb;
    final width = size.width;

    DeviceType deviceType;
    if (width < ResponsiveConfig.instance.breakpoints[DeviceType.mobile]!) {
      deviceType = DeviceType.mobile;
    } else if (width < ResponsiveConfig.instance.breakpoints[DeviceType.tablet]!) {
      deviceType = DeviceType.tablet;
    } else if (width < ResponsiveConfig.instance.breakpoints[DeviceType.desktop]!) {
      deviceType = DeviceType.desktop;
    } else {
      deviceType = DeviceType.largeDesktop;
    }
    DeviceOS os;
    if (isWeb) {
      os = DeviceOS.web;
    } else if (Platform.isAndroid) {
      os = DeviceOS.android;
    } else if (Platform.isIOS) {
      os = DeviceOS.ios;
    } else if (Platform.isWindows) {
      os = DeviceOS.windows;
    } else if (Platform.isMacOS) {
      os = DeviceOS.macos;
    } else {
      os = DeviceOS.linux;
    }

    return DeviceInfo._(
      type: deviceType,
      os: os,
      orientation: orientation,
      width: width,
      height: size.height,
      pixelRatio: pixelRatio,
      isWeb: isWeb,
      isMobile: deviceType == DeviceType.mobile,
      isTablet: deviceType == DeviceType.tablet,
      isDesktop: deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop,
    );
  }
}