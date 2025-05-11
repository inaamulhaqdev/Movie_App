import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptimizedSelector<T, R> extends StatefulWidget {
  final R Function(BuildContext context, T value) selector;
  final Widget Function(BuildContext context, R value, Widget? child) builder;
  final bool Function(R previous, R next)? shouldRebuild;
  final Widget? child;

  const OptimizedSelector({
    super.key,
    required this.selector,
    required this.builder,
    this.shouldRebuild,
    this.child,
  });

  @override
  State<OptimizedSelector<T, R>> createState() =>
      _OptimizedSelectorState<T, R>();
}

class _OptimizedSelectorState<T, R> extends State<OptimizedSelector<T, R>> {
  @override
  Widget build(BuildContext context) {
    return Selector<T, R>(
      selector: widget.selector,
      builder: widget.builder,
      shouldRebuild:
          widget.shouldRebuild ??
          (previous, next) {
            if (previous is List && next is List) {
              if (previous.length != next.length) return true;
            }
            return previous != next;
          },
      child: widget.child,
    );
  }
}
