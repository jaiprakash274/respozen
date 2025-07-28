// Enhanced ResponsiveHelper with better overflow prevention
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:respozen/src/responsive_config.dart';
import 'device_info.dart';

class ResponsiveHelper {
  static BuildContext? _context;
  static DeviceInfo? _deviceInfo;
  static MediaQueryData? _mediaQuery;

  // Cache for performance
  static double? _cachedSafeWidth;
  static double? _cachedSafeHeight;
  static Size? _lastScreenSize;

  // Check if initialized
  static bool get isInitialized => _context != null && _deviceInfo != null && _mediaQuery != null;

  static void init(BuildContext context) {
    _context = context;
    _deviceInfo = DeviceInfo.fromContext(context);
    _mediaQuery = MediaQuery.of(context);

    // Reset cache if screen size changed
    if (_lastScreenSize != _mediaQuery!.size) {
      _cachedSafeWidth = null;
      _cachedSafeHeight = null;
      _lastScreenSize = _mediaQuery!.size;
    }
  }

  // Safe access to deviceInfo
  static DeviceInfo? get deviceInfo {
    if (!isInitialized) {
      return null;
    }
    return _deviceInfo!;
  }

  static MediaQueryData? get mediaQuery {
    if (!isInitialized) {
      return null;
    }
    return _mediaQuery!;
  }

  // Original methods (keeping compatibility)
  static double scaleWidth(double width) {
    if (!isInitialized) return width;
    return (width / ResponsiveConfig.instance.designWidth) * deviceInfo!.width;
  }

  static double scaleHeight(double height) {
    if (!isInitialized) return height;
    return (height / ResponsiveConfig.instance.designHeight) * deviceInfo!.height;
  }

  // Enhanced safe scaling with minimum viable size
  static double safeScaleWidth(double width, {
    double minSize = 1.0,
    double maxPercentage = 0.95,
    bool respectPadding = true,
  }) {
    if (!isInitialized) return width;
    
    double scaledWidth = scaleWidth(width);
    double availableWidth = deviceInfo!.width;
    
    if (respectPadding && mediaQuery != null) {
      availableWidth -= mediaQuery!.padding.horizontal;
    }

    double maxAllowed = availableWidth * maxPercentage;
    double result = math.min(scaledWidth, maxAllowed);

    return math.max(result, minSize);
  }

  static double safeScaleHeight(double height, {
    double minSize = 1.0,
    double maxPercentage = 0.95,
  }) {
    if (!isInitialized) return height;
    
    double scaledHeight = scaleHeight(height);
    double availableHeight = safeAreaHeight;
    double maxAllowed = availableHeight * maxPercentage;
    double result = math.min(scaledHeight, maxAllowed);
    return math.max(result, minSize);
  }

  // Minimum and maximum constraints
  static double minScaleWidth(double width) {
    double scaledWidth = scaleWidth(width);
    return math.max(scaledWidth, 1.0); // Minimum 1px
  }

  static double maxScaleWidth(double width) {
    double scaledWidth = scaleWidth(width);
    return math.min(scaledWidth, deviceInfo!.width * 0.9);
  }

  // Adaptive scaling based on device type
  static double adaptiveWidth(double width) {
    if (!isInitialized) return width;
    
    double baseScale = scaleWidth(width);

    switch (deviceInfo!.type) {
      case DeviceType.mobile:
        return baseScale;
      case DeviceType.tablet:
        return baseScale * 0.9;
      case DeviceType.desktop:
        return math.max(baseScale * 0.8, width);
      case DeviceType.largeDesktop:
        return math.min(baseScale * 0.7, width * 1.5);
    }
  }

  static double adaptiveHeight(double height) {
    if (!isInitialized) return height;
    
    double baseScale = scaleHeight(height);

    // Orientation ke according adjust kare
    if (deviceInfo!.orientation == Orientation.landscape && deviceInfo!.isMobile) {
      return baseScale * 0.7; // Landscape me height kam kare
    }

    return baseScale;
  }

  // Enhanced font scaling with better readability
  static double scaleFont(double fontSize, {
    bool considerViewingDistance = true,
  }) {
    if (!isInitialized) return fontSize;
    
    double baseScale = scaleWidth(fontSize);

    // Device-specific font adjustments
    double multiplier = 1.0;
    switch (deviceInfo!.type) {
      case DeviceType.mobile:
        multiplier = considerViewingDistance ? 1.0 : 0.95;
        break;
      case DeviceType.tablet:
        multiplier = considerViewingDistance ? 1.1 : 1.0;
        break;
      case DeviceType.desktop:
        multiplier = considerViewingDistance ? 1.2 : 1.1;
        break;
      case DeviceType.largeDesktop:
        multiplier = considerViewingDistance ? 1.3 : 1.2;
        break;
    }

    double scaledFont = baseScale * multiplier;

    // Dynamic clamping based on screen size
    double minFont, maxFont;
    switch (deviceInfo!.type) {
      case DeviceType.mobile:
        minFont = 8.0;
        maxFont = math.min(32.0, deviceInfo!.width * 0.08);
        break;
      case DeviceType.tablet:
        minFont = 10.0;
        maxFont = math.min(48.0, deviceInfo!.width * 0.06);
        break;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        minFont = 12.0;
        maxFont = math.min(64.0, deviceInfo!.width * 0.04);
        break;
    }

    return scaledFont.clamp(minFont, maxFont);
  }

  static double scaleRadius(double radius) {
    return safeScaleWidth(radius);
  }

  static double scaleSpacing(double spacing) {
    return safeScaleWidth(spacing);
  }

  // Cached safe area calculations
  static double get safeAreaWidth {
    if (!isInitialized || deviceInfo == null || mediaQuery == null) return 0;
    return _cachedSafeWidth ??= deviceInfo!.width - mediaQuery!.padding.horizontal;
  }

  static double get safeAreaHeight {
    if (!isInitialized || deviceInfo == null || mediaQuery == null) return 0;
    return _cachedSafeHeight ??= deviceInfo!.height -
        mediaQuery!.padding.vertical -
        mediaQuery!.viewInsets.bottom;
  }

  // Grid system for complex layouts
  static double gridWidth(int columns, {double gap = 16}) {
    double totalGap = (columns - 1) * scaleWidth(gap);
    return (safeAreaWidth - totalGap) / columns;
  }

  // Advanced breakpoint system
  static T responsiveValue<T>({
    required T mobile,
    T? mobileLandscape,
    T? tablet,
    T? tabletLandscape,
    T? desktop,
    T? largeDesktop,
  }) {
    if (!isInitialized) return mobile;
    
    bool isLandscape = deviceInfo!.orientation == Orientation.landscape;

    switch (deviceInfo!.type) {
      case DeviceType.mobile:
        if (isLandscape && mobileLandscape != null) return mobileLandscape;
        return mobile;
      case DeviceType.tablet:
        if (isLandscape && tabletLandscape != null) return tabletLandscape;
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  // Overflow detection and prevention
  static bool willOverflow({
    required double contentWidth,
    required double contentHeight,
    EdgeInsets? padding,
  }) {
    double availableWidth = safeAreaWidth;
    double availableHeight = safeAreaHeight;

    if (padding != null) {
      availableWidth -= padding.horizontal;
      availableHeight -= padding.vertical;
    }

    return contentWidth > availableWidth || contentHeight > availableHeight;
  }

  // Auto-fit content with overflow prevention
  static double autoFitWidth(double contentWidth, {
    double padding = 0,
    double minScale = 0.1,
  }) {
    double availableWidth = safeAreaWidth - padding;

    if (contentWidth <= availableWidth) return contentWidth;

    double scale = availableWidth / contentWidth;
    return contentWidth * math.max(scale, minScale);
  }

  // Intelligent container sizing
  static Size getOptimalContainerSize({
    double? width,
    double? height,
    double? aspectRatio,
    bool maintainAspectRatio = false,
  }) {
    double? finalWidth = width?.let((w) => safeScaleWidth(w));
    double? finalHeight = height?.let((h) => safeScaleHeight(h));

    if (maintainAspectRatio && aspectRatio != null) {
      if (finalWidth != null && finalHeight == null) {
        finalHeight = finalWidth / aspectRatio;
      } else if (finalHeight != null && finalWidth == null) {
        finalWidth = finalHeight * aspectRatio;
      }
    }

    return Size(
      finalWidth ?? double.infinity,
      finalHeight ?? double.infinity,
    );
  }
}

// Extension for null safety helper
extension NullableHelper<T> on T? {
  R? let<R>(R Function(T) block) {
    final value = this;
    return value != null ? block(value) : null;
  }
}

// Safe extension methods that check initialization
extension ResponsiveExtension on num {
  double get rw {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.scaleWidth(toDouble());
  }
  
  double get rh {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.scaleHeight(toDouble());
  }
  
  double get rf {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.scaleFont(toDouble());
  }
  
  double get rr {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.scaleRadius(toDouble());
  }
  
  double get rs {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.scaleSpacing(toDouble());
  }
  
  double get srw {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.safeScaleWidth(toDouble());
  }
  
  double get srh {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.safeScaleHeight(toDouble());
  }
  
  double get minRw {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.minScaleWidth(toDouble());
  }
  
  double get maxRw {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.maxScaleWidth(toDouble());
  }
  
  double get aw {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.adaptiveWidth(toDouble());
  }
  
  double get ah {
    if (!ResponsiveHelper.isInitialized) {
      debugPrint('Warning: ResponsiveHelper not initialized. Using fallback value.');
      return toDouble();
    }
    return ResponsiveHelper.adaptiveHeight(toDouble());
  }
}

extension ContextExtension on BuildContext {
  DeviceInfo get device => DeviceInfo.fromContext(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => device.isMobile;
  bool get isTablet => device.isTablet;
  bool get isDesktop => device.isDesktop;
  bool get isPortrait => device.orientation == Orientation.portrait;
  bool get isLandscape => device.orientation == Orientation.landscape;
}