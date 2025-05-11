import 'package:flutter/material.dart';

class OptimizedContainer extends StatelessWidget {
  final Widget child;
  final bool useRepaintBoundary;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Alignment? alignment;

  const OptimizedContainer({
    super.key,
    required this.child,
    this.useRepaintBoundary = true,
    this.color,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints,
      width: width,
      height: height,
      color: decoration == null ? color : null,
      alignment: alignment,
      child: child,
    );

    if (useRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }

    return result;
  }
}
