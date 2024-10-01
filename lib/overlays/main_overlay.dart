import 'dart:async';
import 'package:flutter/material.dart';

class DragOverlayLogic extends StatefulWidget {
  @override
  _DragOverlayLogicState createState() => _DragOverlayLogicState();
}

class _DragOverlayLogicState extends State<DragOverlayLogic> {
  Offset initialPosition = Offset(0, 0);
  Offset finalPosition = Offset(0, 0);
  bool isDrawing = false;
  Timer? holdTimer;
  bool isHeld = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: <Widget>[
            // CustomPainter for drawing the rectangle

            // Draggable Icon
            Positioned(
              left: finalPosition.dx,
              top: finalPosition.dy,
              child: GestureDetector(
                onPanDown: (_) {
                  // Start a timer for 1 second hold
                  holdTimer = Timer(Duration(seconds: 1), () {
                    setState(() {
                      isHeld = true; // Mark as held
                    });
                  });
                },
                onPanCancel: () => holdTimer?.cancel(),
                onPanEnd: (_) => holdTimer?.cancel(),
                child: Draggable(
                  feedback: buildDraggableIcon(),
                  child: buildDraggableIcon(),
                  onDragStarted: () {
                    if (isHeld) {
                      setState(() {
                        initialPosition =
                            finalPosition; // Set initial drag position
                        isDrawing = true; // Start drawing
                      });
                    }
                  },
                  onDragUpdate: (details) {
                    // Update final position dynamically
                    setState(() {
                      finalPosition =
                          _clampPosition(details.globalPosition, constraints);
                    });
                  },
                  onDragEnd: (details) {
                    // Finish drawing and capture final position
                    setState(() {
                      isDrawing = false;
                      print("Initial Position: $initialPosition");
                      print("Final Position: $finalPosition");
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper function to clamp the draggable position within screen bounds
  Offset _clampPosition(Offset offset, BoxConstraints constraints) {
    double dx = offset.dx.clamp(0.0, constraints.maxWidth - 50);
    double dy = offset.dy.clamp(0.0, constraints.maxHeight - 50);
    return Offset(dx, dy);
  }

  // Build the draggable icon
  Widget buildDraggableIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      child: Icon(Icons.circle, color: Colors.white),
    );
  }
}

// CustomPainter for drawing the rectangle
class RectanglePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  RectanglePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
