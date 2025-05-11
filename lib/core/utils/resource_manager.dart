import 'dart:async';
import 'package:flutter/material.dart';

class ResourceManager {
  final List<StreamSubscription?> _subscriptions = [];
  final List<ChangeNotifier?> _changeNotifiers = [];
  final List<VoidCallback> _disposeCallbacks = [];

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void addNotifier(ChangeNotifier notifier) {
    _changeNotifiers.add(notifier);
  }

  void addDisposeCallback(VoidCallback callback) {
    _disposeCallbacks.add(callback);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
    _subscriptions.clear();

    for (final notifier in _changeNotifiers) {
      notifier?.dispose();
    }
    _changeNotifiers.clear();

    for (final callback in _disposeCallbacks) {
      callback();
    }
    _disposeCallbacks.clear();
  }

  R manage<R extends ChangeNotifier>(R notifier) {
    addNotifier(notifier);
    return notifier;
  }
}

mixin ResourceManagerMixin<T extends StatefulWidget> on State<T> {
  final ResourceManager resourceManager = ResourceManager();

  @override
  void dispose() {
    resourceManager.dispose();
    super.dispose();
  }

  void manageSubscription(StreamSubscription subscription) {
    resourceManager.addSubscription(subscription);
  }

  void manageNotifier(ChangeNotifier notifier) {
    resourceManager.addNotifier(notifier);
  }

  void addDisposeCallback(VoidCallback callback) {
    resourceManager.addDisposeCallback(callback);
  }

  R manage<R extends ChangeNotifier>(R notifier) {
    return resourceManager.manage<R>(notifier);
  }
}
