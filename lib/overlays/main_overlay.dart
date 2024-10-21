// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'dart:async';

import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:on_screen_ocr/overlays/img.dart';

class DragAndHoldExample extends StatefulWidget {
  const DragAndHoldExample({super.key});

  @override
  DragAndHoldExampleState createState() => DragAndHoldExampleState();
}

class DragAndHoldExampleState extends State<DragAndHoldExample> {
  Offset finalPos = const Offset(100, 100);
  Offset? initPos;
  Timer? holdTimer;
  bool isHolding = false;

  @override
  void dispose() {
    holdTimer?.cancel();
    super.dispose();
  }

  void startHoldTimer(Offset newPosition) {
    holdTimer?.cancel();
    !isHolding ? initPos = newPosition : null;
    // initPos = newPosition;

    holdTimer = Timer(const Duration(milliseconds: 700), () {
      if (!isHolding) {
        setState(() {
          isHolding = true;
        });
        print('Held at initpPos: $initPos for 1 second');
      }
    });
  }

  Future<String?> getLatestScreenshot() async {
    // Try using MediaStore to get latest screenshot from Pictures/Screenshots directory.
    final screenshotsDir =
        Directory('/storage/emulated/0/Pictures/Screenshots');

    if (await screenshotsDir.exists()) {
      List<FileSystemEntity> files = screenshotsDir.listSync();

      // Sort files by last modified time to get the latest one.
      files.sort((a, b) {
        return File(b.path)
            .lastModifiedSync()
            .compareTo(File(a.path).lastModifiedSync());
      });

      if (files.isNotEmpty) {
        return files.first.path;
      }
    }
    return null;
  }

  String? path;

//TODO: Implement the onPanEnd method
  void onPanEnd(DragEndDetails details) async {
    if (isHolding) {
      holdTimer?.cancel();
      print('Drag ended at: $finalPos');

      print("drag alls");
      print((finalPos.dx - initPos!.dx) / 1);
      print((finalPos.dy - initPos!.dy) / 1);
      isHolding = false;
      print(
        "finalPos: $finalPos, initPos: $initPos",
      );
      await Future.delayed(const Duration(milliseconds: 50));

      FlutterAccessibilityService.performGlobalAction(
        GlobalAction.globalActionTakeScreenshot,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      String? pth = await getLatestScreenshot();

      path = pth;
      await FlutterOverlayWindow.resizeOverlay(200, 400, true);
      setState(() {});
    }
  }

  void onPanStart(DragStartDetails details) {
    print('Drag started ');
    startHoldTimer(finalPos);
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      finalPos += details.globalPosition;
    });

    if (initPos != null && (finalPos - initPos!).distance > 10) {
      holdTimer?.cancel();
      startHoldTimer(finalPos);
    }
  }

  void onCancel() {
    print('Canceled');
    isHolding = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child:
          // path != null
          //     ? ImageCropper(imagePath: path!, offset1: initPos!, offset2: finalPos)
          //     :
          GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Icon(
          Icons.location_on,
          color: isHolding ? Colors.green : Colors.blue,
          size: 40,
        ),
      ),
    );
  }
}
