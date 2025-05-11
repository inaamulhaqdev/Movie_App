import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ValueNotifier<bool> isConnected = ValueNotifier<bool>(true);

  final StreamController<bool> _connectionChangeController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  ConnectivityService() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    isConnected.value = true;
    _connectionChangeController.add(true);
  }

  Future<bool> hasInternetConnection() async {
    return isConnected.value;
  }

  StreamSubscription<bool> onConnectivityChanged(
    void Function(bool isConnected) callback,
  ) {
    return connectionChange.listen(callback);
  }

  Future<T> retryWithBackoff<T>({
    required Future<T> Function() function,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempts++;
        return await function();
      } catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }

        if (!await hasInternetConnection()) {
          throw Exception('No internet connection available');
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  void dispose() {
    _connectionChangeController.close();
    isConnected.dispose();
  }
}
