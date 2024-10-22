// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:native_image_cropper/native_image_cropper.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_clipboard/super_clipboard.dart';

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});

  @override
  OverlayWidgetState createState() => OverlayWidgetState();
}

class OverlayWidgetState extends State<OverlayWidget> {
  BoxShape _currentShape = BoxShape.circle;
  String? path;
  late CropController controller;
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
        onTap: () async {
          if (_currentShape == BoxShape.rectangle) {
            // if (await OverlayPopUp.isActive()) {
            //   await OverlayPopUp.updateOverlaySize(width: 100, height: 100);
            // }

            // setState(() {
            //   _currentShape = BoxShape.circle;
            // });
          } else {
            FlutterAccessibilityService.performGlobalAction(
              GlobalAction.globalActionTakeScreenshot,
            );
            controller = CropController();
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) async {
              String? pth = await getLatestScreenshot();
              path = pth;
              loadImage(path!);
            });
            await Future.delayed(const Duration(milliseconds: 1000));
            setState(() {
              _currentShape = BoxShape.rectangle;
            });
            if (await OverlayPopUp.isActive()) {
              await OverlayPopUp.updateOverlaySize();
            }
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.rectangle,
          ),
          child: Center(
            child:

                //  Column(
                //   mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                _currentShape == BoxShape.rectangle
                    ? PopScope(
                        canPop: false,
                        onPopInvokedWithResult: (didPop, result) async {
                          if (await OverlayPopUp.isActive()) {
                            await OverlayPopUp.updateOverlaySize(
                                width: 100, height: 100);
                          }

                          setState(() {
                            _currentShape = BoxShape.circle;
                          });
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: CropPreview(
                                controller: controller,
                                mode: CropMode.rect,
                                bytes: _imageBytes!,
                                dragPointSize: 20,
                                hitSize: 20,
                                dragPointBuilder: (size, position) {
                                  if (position ==
                                      CropDragPointPosition.topLeft) {
                                    return CropDragPoint(
                                        size: size, color: Colors.red);
                                  }
                                  return CropDragPoint(
                                      size: size, color: Colors.blue);
                                },
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () async {
                                        _currentShape = BoxShape.circle;
                                        if (await OverlayPopUp.isActive()) {
                                          await OverlayPopUp.updateOverlaySize(
                                              width: 100, height: 100);
                                        }
                                        // await FlutterOverlayWindow.resizeOverlay(
                                        //     50, 100, true);

                                        setState(() {});
                                        _imageBytes = null;
                                        path = null;
                                        controller.dispose();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.crop),
                                      onPressed: () async {
                                        final croppedBytes =
                                            await controller.crop();
                                        var tmpFile =
                                            await _createTempFile(croppedBytes);
                                        var file = tmpFile;
                                        final inputImage =
                                            InputImage.fromFile(file);
                                        final textRecognizer = TextRecognizer(
                                            script:
                                                TextRecognitionScript.latin);
                                        final RecognizedText recognizedText =
                                            await textRecognizer
                                                .processImage(inputImage);
                                        print(recognizedText.text);
                                        final clipboard =
                                            SystemClipboard.instance;
                                        if (clipboard == null) {
                                          print("lul");
                                          return; // Clipboard API is not supported on this platform.
                                        }
                                        final item = DataWriterItem();
                                        item.add(Formats.plainText(
                                            recognizedText.text));
                                        await clipboard.write([item]);
                                        // await Clipboard.setData(
                                        //     ClipboardData(text: "your text to copy"));

                                        _currentShape = BoxShape.circle;
                                        if (await OverlayPopUp.isActive()) {
                                          await OverlayPopUp.updateOverlaySize(
                                              width: 100, height: 100);
                                        }
                                        // await FlutterOverlayWindow.resizeOverlay(
                                        //     50, 100, true);

                                        setState(() {});
                                        _imageBytes = null;
                                        path = null;
                                        controller.dispose();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
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
