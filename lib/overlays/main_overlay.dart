// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'dart:async';

import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

class DragAndHoldExample extends StatefulWidget {
  const DragAndHoldExample({super.key});

  @override
  DragAndHoldExampleState createState() => DragAndHoldExampleState();
}

class DragAndHoldExampleState extends State<DragAndHoldExample> {
  Offset finalPos = const Offset(100, 100);
  Offset? initialPosition;
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

  late int x1, x2, x3, x4, y1, y2, y3, y4;

//TODO: Implement the onPanEnd method
  void onPanEnd(DragEndDetails details) async {
    holdTimer?.cancel();
    print('Drag ended at: $finalPos');
    isHolding = false;
    print(
      "finalPos: $finalPos, initialPosition: $initialPosition, initPos: $initPos",
    );

    FlutterAccessibilityService.performGlobalAction(
      GlobalAction.globalActionTakeScreenshot,
    );
  }

  void onPanStart(DragStartDetails details) {
    initialPosition = finalPos;
    print('Drag started at: $initialPosition');
    startHoldTimer(finalPos);
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      finalPos += details.delta;
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
      child: GestureDetector(
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
