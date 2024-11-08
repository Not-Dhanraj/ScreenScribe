import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';

class FirstTaskHandler extends TaskHandler {
  int updateCount = 0;
  int counter = 0;

  void startCameraStream() {}

  @override
  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    log('onButtonPressed >> $id -- $updateCount');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // TODO: implement onRepeatEvent
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await OverlayPopUp.showOverlay(
        height: 100,
        width: 100,
        isDraggable: true,
        verticalAlignment: Gravity.end,
        horizontalAlignment: Gravity.end);
    print("Done");
  }
}
