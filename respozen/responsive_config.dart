import 'device_info.dart';

class ResponsiveConfig {
  static ResponsiveConfig? _instance;
  static ResponsiveConfig get instance => _instance ??= ResponsiveConfig._();
  ResponsiveConfig._();

  // Design reference dimensions (figma/design ke dimensions)
  double designWidth = 375.0;  // iPhone design width
  double designHeight = 812.0; // iPhone design height


  // Breakpoints
  final Map<DeviceType, double> breakpoints = {
    DeviceType.mobile: 600,
    DeviceType.tablet: 1024,
    DeviceType.desktop: 1440,
    DeviceType.largeDesktop: 1920,
  };

  void initialize({
    required double designWidth,
    required double designHeight,
    Map<DeviceType, double>? customBreakpoints,
  }) {
    this.designWidth = designWidth;
    this.designHeight = designHeight;
    if (customBreakpoints != null) {
      breakpoints.addAll(customBreakpoints);
    }
  }
}
