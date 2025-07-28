import 'package:flutter/material.dart';
import 'package:respozen/src/responsive_helper.dart';
import 'device_info.dart';


class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceInfo device) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final device = DeviceInfo.fromContext(context);
    return builder(context, device);
  }
}


class MultiResponsiveBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget Function(BuildContext context, DeviceInfo device)? builder;

  const MultiResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    final device = DeviceInfo.fromContext(context);

    if (builder != null) {
      return builder!(context, device);
    }

    switch (device.type) {
      case DeviceType.mobile:
        return mobile ?? _fallbackWidget(context, device);
      case DeviceType.tablet:
        return tablet ?? mobile ?? _fallbackWidget(context, device);
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? _fallbackWidget(context, device);
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile ?? _fallbackWidget(context, device);
    }
  }
  Widget _fallbackWidget(BuildContext context, DeviceInfo device) {
    return Center(
      child: Text('No widget provided for ${device.type}'),
    );
  }
}