import 'package:flutter/foundation.dart';

class ComputeUtil {
  static Future<T> parseJsonInBackground<T>(
    String jsonString,
    T Function(String json) parseFunction,
  ) async {
    return compute(parseFunction, jsonString);
  }

  static Future<List<R>> processListInBackground<T, R>(
    List<T> items,
    R Function(T item) processFunction,
  ) async {
    if (items.length < 10) {
      return items.map(processFunction).toList();
    }

    return compute(
      _processListHelper<T, R>,
      _ProcessListParam(items, processFunction),
    );
  }

  static List<R> _processListHelper<T, R>(_ProcessListParam<T, R> param) {
    return param.items.map(param.processFunction).toList();
  }
}

class _ProcessListParam<T, R> {
  final List<T> items;
  final R Function(T) processFunction;

  _ProcessListParam(this.items, this.processFunction);
}
