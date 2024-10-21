import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // Image processing package

class ImageCropper extends StatefulWidget {
  final String imagePath; // Path to the image
  final Offset offset1; // Top-left corner
  final Offset offset2; // Bottom-right corner

  ImageCropper(
      {required this.imagePath, required this.offset1, required this.offset2});

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  Uint8List? _croppedImage;

  // Two offsets provided (these could be in any order)

  @override
  void initState() {
    super.initState();
    _cropImage();
  }

  Future<void> _cropImage() async {
    // Load the image from the provided file path
    final File imageFile = File(widget.imagePath);

    if (await imageFile.exists()) {
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode image for processing
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage != null) {
        // Determine the top-left and bottom-right corners
        final int left = widget.offset1.dx < widget.offset2.dx
            ? widget.offset1.dx.toInt()
            : widget.offset2.dx.toInt();
        final int top = widget.offset1.dy < widget.offset2.dy
            ? widget.offset1.dy.toInt()
            : widget.offset2.dy.toInt();
        final int right = widget.offset1.dx > widget.offset2.dx
            ? widget.offset1.dx.toInt()
            : widget.offset2.dx.toInt();
        final int bottom = widget.offset1.dy > widget.offset2.dy
            ? widget.offset1.dy.toInt()
            : widget.offset2.dy.toInt();

        // Calculate the width and height of the cropping area
        final int cropWidth = (right - left).abs();
        final int cropHeight = (bottom - top).abs();

        // Crop the image using the calculated top-left and bottom-right coordinates
        img.Image croppedImage = img.copyCrop(
          originalImage,
          x: left, // X coordinate of the top-left corner
          y: top, // Y coordinate of the top-left corner
          width: cropWidth, // Width of the cropped area
          height: cropHeight, // Height of the cropped area
        );

        // Convert cropped image back to Uint8List for displaying
        Uint8List croppedImageBytes =
            Uint8List.fromList(img.encodePng(croppedImage));

        setState(() {
          _croppedImage = croppedImageBytes;
        });
      }
    } else {
      print('Image file does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _croppedImage != null
          ? Image.memory(_croppedImage!)
          : Text('Cropping image...'),
    );
  }
}
