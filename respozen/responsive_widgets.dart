import 'package:flutter/material.dart';
import 'package:respozen/src/responsive_helper.dart';


// Enhanced RContainer with auto-fit capability
class RContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;
  final bool autoFit;
  final bool preventOverflow;
  final bool useAdaptiveScaling;
  final double? aspectRatio;
  final double minScale;

  const RContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.autoFit = false,
    this.preventOverflow = true,
    this.useAdaptiveScaling = false,
    this.aspectRatio,
    this.minScale = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    double? finalWidth;
    double? finalHeight;

    if (aspectRatio != null && width != null && height == null) {
      // Aspect ratio maintain kare
      finalWidth = preventOverflow ? width!.srw : width!.rw;
      finalHeight = finalWidth / aspectRatio!;
    } else if (aspectRatio != null && height != null && width == null) {
      finalHeight = preventOverflow ? height!.srh : height!.rh;
      finalWidth = finalHeight * aspectRatio!;
    } else {
      // Normal width/height calculation
      if (width != null) {
        if (preventOverflow) {
          finalWidth = useAdaptiveScaling ? width!.aw : width!.srw;
        } else {
          finalWidth = width!.rw;
        }
      }

      if (height != null) {
        if (preventOverflow) {
          finalHeight = useAdaptiveScaling ? height!.ah : height!.srh;
        } else {
          finalHeight = height!.rh;
        }
      }
    }

    // Auto-fit functionality
    if (autoFit && finalWidth != null) {
      finalWidth = ResponsiveHelper.autoFitWidth(
        finalWidth,
        padding: _getPaddingValue(padding),
        minScale: minScale,
      );
    }

    return Container(
      width: finalWidth,
      height: finalHeight,
      padding: _getResponsivePadding(padding),
      margin: _getResponsivePadding(margin),
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  double _getPaddingValue(EdgeInsetsGeometry? padding) {
    if (padding == null) return 0;
    if (padding is EdgeInsets) {
      return padding.horizontal;
    }
    return 32; // Default padding
  }

  EdgeInsetsGeometry? _getResponsivePadding(EdgeInsetsGeometry? padding) {
    if (padding == null) return null;

    if (padding is EdgeInsets) {
      return EdgeInsets.only(
        left: padding.left.srw,
        top: padding.top.srh,
        right: padding.right.srw,
        bottom: padding.bottom.srh,
      );
    }
    return EdgeInsets.all(16.rs); // fallback
  }
}

class RText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool preventOverflow;

  const RText(
      this.text, {
        super.key,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.preventOverflow = true,
      });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize?.rf ?? 14.rf,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: preventOverflow ? (overflow ?? TextOverflow.ellipsis) : overflow,
    );
  }
}

class RSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final bool preventOverflow;

  const RSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
    this.preventOverflow = true,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return SizedBox(width: width != null ? (preventOverflow ? width!.srw : width!.rw) : null,
      height: height != null ? (preventOverflow ? height!.srh : height!.rh) : null,
      child: child,
    );
  }
}

class RFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? gap;
  final bool preventOverflow;

  const RFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.gap,
    this.preventOverflow = true,
  });
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1 && gap != null) {
        if (direction == Axis.horizontal) {
          spacedChildren.add(RSizedBox(width: gap));
        } else {
          spacedChildren.add(RSizedBox(height: gap));
        }
      }
    }
    Widget flexWidget = Flex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );

    // Overflow protection
    if (preventOverflow) {
      if (direction == Axis.horizontal) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(child: flexWidget),
        );
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: IntrinsicHeight(child: flexWidget),
        );
      }
    }
    return flexWidget;
  }
}

class RColumn extends RFlex {
  const RColumn({
    super.key,
    required super.children,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.gap,
    super.preventOverflow,
  }) : super(
    direction: Axis.vertical,
  );
}

class RRow extends RFlex {
  const RRow({
    super.key,
    required super.children,
    super.mainAxisAlignment,
    super.crossAxisAlignment,
    super.gap,
    super.preventOverflow,
  }) : super(
    direction: Axis.horizontal,
  );
}

// Grid system for complex layouts
class RGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double? gap;
  final bool preventOverflow;

  const RGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.gap,
    this.preventOverflow = true,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    double itemWidth = ResponsiveHelper.gridWidth(
      crossAxisCount,
      gap: gap ?? 16,
    );

    List<Widget> rows = [];
    for (int i = 0; i < children.length; i += crossAxisCount) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < crossAxisCount && i + j < children.length; j++) {
        rowChildren.add(
          SizedBox(
            width: itemWidth,
            child: children[i + j],
          ),
        );
      }
      rows.add(
        RRow(
          gap: gap,
          preventOverflow: preventOverflow,
          children: rowChildren,
        ),
      );
    }

    return RColumn(
      gap: gap,
      preventOverflow: preventOverflow,
      children: rows,
    );
  }
}
