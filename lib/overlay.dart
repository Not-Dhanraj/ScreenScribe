import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  OverlayWidgetState createState() => OverlayWidgetState();
}

class OverlayWidgetState extends State<OverlayWidget> {
  Color color = const Color(0xFFFFFFFF);
  BoxShape _currentShape = BoxShape.circle;
  static const String _kPortNameHome = 'UI';
  SendPort? homePort;
  String? path;
  String? messageFromOverlay;
  final controller = CropController();
  Uint8List? _imageBytes;

  Future<void> loadImage(String path) async {
    String imagePath = path; // Replace with your image path
    Uint8List imageBytes = await convertImageToUint8List(imagePath);
    setState(() {
      _imageBytes = imageBytes;
    });
  }

  Future<Uint8List> convertImageToUint8List(String imagePath) async {
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    return imageBytes;
  }

  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_currentShape == BoxShape.rectangle) {
            await FlutterOverlayWindow.resizeOverlay(50, 100, true);
            setState(() {
              _currentShape = BoxShape.circle;
            });
          } else {
            FlutterAccessibilityService.performGlobalAction(
              GlobalAction.globalActionTakeScreenshot,
            );

            await Future.delayed(const Duration(milliseconds: 1000))
                .then((value) async {
              String? pth = await getLatestScreenshot();
              path = pth;
              loadImage(path!);
            });
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {
              _currentShape = BoxShape.rectangle;
            });
            await FlutterOverlayWindow.resizeOverlay(
              // WindowSize.matchParent,
              // WindowSize.matchParent,
              410, 860,
              false,
            );
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: _currentShape,
          ),
          child: Center(
            child:

                //  Column(
                //   mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                _currentShape == BoxShape.rectangle
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 600,
                            width: 400,
                            child: CropPreview(
                              controller: controller,
                              mode: CropMode.rect,
                              bytes: _imageBytes!,
                              dragPointSize: 20,
                              hitSize: 20,
                              dragPointBuilder: (size, position) {
                                if (position == CropDragPointPosition.topLeft) {
                                  return CropDragPoint(
                                      size: size, color: Colors.red);
                                }
                                return CropDragPoint(
                                    size: size, color: Colors.blue);
                              },
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.crop),
                                onPressed: () async {
                                  final croppedBytes = await controller.crop();
                                  var tmpFile =
                                      await _createTempFile(croppedBytes!);
                                  var file = tmpFile;
                                  final inputImage = InputImage.fromFile(file);
                                  final textRecognizer = TextRecognizer(
                                      script: TextRecognitionScript.latin);
                                  final RecognizedText recognizedText =
                                      await textRecognizer
                                          .processImage(inputImage);
                                  print(recognizedText.text);

                                  // await Clipboard.setData(
                                  //     ClipboardData(text: "your text to copy"));

                                  _currentShape = BoxShape.circle;
                                  await FlutterOverlayWindow.resizeOverlay(
                                      50, 100, true);

                                  setState(() {});
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : const SizedBox.shrink(),
            //   _currentShape == BoxShape.rectangle
            //       ? messageFromOverlay == null
            //           ? const FlutterLogo()
            //           : Text(messageFromOverlay ?? '')
            //       : const FlutterLogo()
            // ],
            // ),
          ),
        ),
      ),
    );
  }

  Future<File> _createTempFile(Uint8List imageData) async {
    File tempFile = await convertUint8ListToTempFile(imageData, 'image.png');

    return tempFile;
  }

  Future<File> convertUint8ListToTempFile(
      Uint8List data, String fileName) async {
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(data);
    return tempFile;
  }
}
