// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:async';

class DragAndHoldExample extends StatefulWidget {
  const DragAndHoldExample({super.key});

  @override
  DragAndHoldExampleState createState() => DragAndHoldExampleState();
}

class DragAndHoldExampleState extends State<DragAndHoldExample> {
  Offset position = const Offset(100, 100);
  Offset? initialPosition;
  Offset? holdPosition;
  Timer? holdTimer;
  bool isHolding = false;

  @override
  void dispose() {
    holdTimer?.cancel();
    super.dispose();
  }

  void startHoldTimer(Offset newPosition) {
    holdTimer?.cancel();
    holdPosition = newPosition;

    holdTimer = Timer(const Duration(milliseconds: 700), () {
      setState(() {
        isHolding = true;
      });
      print('Held at position: $holdPosition for 1 second');
    });
  }

  void onPanStart(DragStartDetails details) {
    initialPosition = position;
    print('Drag started at: $initialPosition');
    startHoldTimer(position);
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position += details.delta;
    });

    if (holdPosition != null && (position - holdPosition!).distance > 10) {
      holdTimer?.cancel();
      isHolding = false;
      startHoldTimer(position);
    }
  }

  void onPanEnd(DragEndDetails details) {
    holdTimer?.cancel();
    print('Drag ended at: $position');
    isHolding = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Icon(
        Icons.location_on,
        color: isHolding ? Colors.green : Colors.blue,
        size: 50,
      ),
    );
  }
}
