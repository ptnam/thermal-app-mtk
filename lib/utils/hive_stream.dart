import 'dart:async';

import 'package:hive/hive.dart';

/// Broadcast stream that emits the full box snapshot initially and whenever
/// the box changes. Useful for simple UI wiring with StreamBuilder.
Stream<List<T>> boxSnapshotStream<T>(Box<T> box) {
  final controller = StreamController<List<T>>.broadcast();

  // emit initial snapshot when listener attaches
  void emitSnapshot() {
    if (!controller.isClosed) controller.add(box.values.cast<T>().toList());
  }

  late final StreamSubscription sub;

  controller.onListen = () {
    emitSnapshot();
    sub = box.watch().listen((_) => emitSnapshot());
  };

  controller.onCancel = () async {
    await sub.cancel();
  };

  return controller.stream;
}
