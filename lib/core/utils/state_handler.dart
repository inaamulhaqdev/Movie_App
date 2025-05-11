import 'package:flutter/material.dart';
import 'package:movie_test_app/core/utils/ui_state.dart';
import 'package:movie_test_app/core/utils/error_state.dart' as error_widget;
import 'package:movie_test_app/core/utils/loading_state.dart' as loading_widget;

class StateHandler<T> extends StatelessWidget {
  final UIState<T> state;
  final Widget Function(T data) onSuccess;
  final Widget Function(String message)? onError;
  final Widget Function()? onLoading;
  final VoidCallback? onRetry;

  const StateHandler({
    super.key,
    required this.state,
    required this.onSuccess,
    this.onError,
    this.onLoading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      InitialState() => const SizedBox(),
      LoadingState() =>
        onLoading?.call() ??
            loading_widget.LoadingState(
              message: (state as LoadingState).message,
            ),
      SuccessState<T>() => onSuccess((state as SuccessState<T>).data),
      ErrorState() =>
        onError?.call((state as ErrorState).message) ??
            error_widget.ErrorState(
              message: (state as ErrorState).message,
              onRetry: onRetry,
            ),
      _ => const SizedBox(),
    };
  }
}
