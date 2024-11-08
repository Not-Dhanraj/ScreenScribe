import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';

class FirstTaskHandler extends TaskHandler {
  int updateCount = 0;
  int counter = 0;

  void startCameraStream() {}

  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  void onButtonPressed(String id) {
    log('onButtonPressed >> $id -- $updateCount');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await OverlayPopUp.showOverlay(
      height: 100,
      width: 100,
      isDraggable: true,
    );
    print("Done");
  }
}
