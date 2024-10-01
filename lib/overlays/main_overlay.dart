import 'package:flutter/material.dart';

class FloatingWidget extends StatefulWidget {
  const FloatingWidget({super.key});

  @override
  FloatingWidgetState createState() => FloatingWidgetState();
}

class FloatingWidgetState extends State<FloatingWidget> {
  double xPosition = 100;
  double yPosition = 100;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        print(details.delta.dx.toString() + " " + details.delta.dy.toString());
      },
      child: FloatingActionButton(
        onPressed: () {
          // Define your action when the button is pressed
          print("Floating Button Pressed");
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
