import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/notification_permission.dart';
import 'package:on_screen_ocr/main.dart';
import 'package:on_screen_ocr/task_handler_ov.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? latestMessageFromOverlay;

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      //   // When you call this function, will be gone to the settings page.
      //   // So you need to explain to the user why set it.
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // }
    }
  }

  Future<ServiceRequestResult> _stopService() async {
    return FlutterForegroundTask.stopService();
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.once(),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: false,
        allowWifiLock: false,
      ),
    );
  }

  Future<void> requestNotificationsPermission() async {
    await FlutterAccessibilityService.getSystemActions();
    var hasAccessibilityPermission =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    if (!hasAccessibilityPermission) {
      hasAccessibilityPermission =
          await FlutterAccessibilityService.requestAccessibilityPermission();
    }
    if (hasAccessibilityPermission) {
      await FlutterAccessibilityService.getSystemActions();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request permissions and initialize the service.
      await _requestPermissions();
      _initService();
    });
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'hello'),
        ],
        callback: startCallback,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isPermissionGranted();
                log("Is Permission Granted: $status");
              },
              child: const Text("Check Permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                log("status: $res");
              },
              child: const Text("Request Permission"),
            ),
            TextButton(
              onPressed: () async {
                requestNotificationsPermission();
                final bool? res =
                    await FlutterOverlayWindow.requestPermission();
                log("status: $res");
              },
              child: const Text("Test Thing"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await FlutterAccessibilityService.getSystemActions();

                _startService();

                // await OverlayPopUp.showOverlay(
                //     height: 100,
                //     width: 100,
                //     isDraggable: true,
                //     verticalAlignment: Gravity.end,
                //     horizontalAlignment: Gravity.end);
              },
              child: const Text("Show Overlay"),
            ),
            TextButton(
              onPressed: () async {
                final bool status = await FlutterAccessibilityService
                    .isAccessibilityPermissionEnabled();
                if (!status) {
                  await FlutterAccessibilityService
                      .requestAccessibilityPermission();
                }
              },
              child: const Text("req accessibility"),
            ),
            TextButton(
              onPressed: () async {
                _requestStoragePermission();
              },
              child: const Text("req storage permission"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                final status = await FlutterOverlayWindow.isActive();
                log("Is Active?: $status");
              },
              child: const Text("Is Active?"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                await FlutterOverlayWindow.resizeOverlay(
                  WindowSize.matchParent,
                  (MediaQuery.of(context).size.height * 5).toInt(),
                  false,
                );
              },
              child: const Text("Update Overlay"),
            ),
            const SizedBox(height: 10.0),
            TextButton(
              onPressed: () async {
                log('Try to close');
                _stopService();
                await OverlayPopUp.closeOverlay();
                // .then((value) => log('STOPPED: alue: $value'));
              },
              child: const Text("Close Overlay"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                homePort ??=
                    IsolateNameServer.lookupPortByName(_kPortNameOverlay);
                homePort?.send('Send to overlay: ${DateTime.now()}');
              },
              child: const Text("Send message to overlay"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                FlutterOverlayWindow.getOverlayPosition().then((value) {
                  log('Overlay Position: $value');
                  setState(() {
                    latestMessageFromOverlay = 'Overlay Position: $value';
                  });
                });
              },
              child: const Text("Get overlay position"),
            ),
            const SizedBox(height: 20.0),
            TextButton(
              onPressed: () {
                FlutterOverlayWindow.moveOverlay(
                  const OverlayPosition(0, 0),
                );
              },
              child: const Text("Move overlay position to (0, 0)"),
            ),
            const SizedBox(height: 20),
            Text(latestMessageFromOverlay ?? ''),
          ],
        ),
      ),
    );
  }

  void _requestStoragePermission() async {
    openAppSettings();
  }
}
