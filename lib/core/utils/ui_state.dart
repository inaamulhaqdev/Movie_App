abstract class UIState<T> {
  const UIState();
}

class InitialState<T> extends UIState<T> {
  const InitialState();
}

class LoadingState<T> extends UIState<T> {
  final String? message;
  const LoadingState({this.message});
}

class SuccessState<T> extends UIState<T> {
  final T data;
  const SuccessState(this.data);
}

class ErrorState<T> extends UIState<T> {
  final String message;
  final Exception? error;

  const ErrorState({required this.message, this.error});
}
