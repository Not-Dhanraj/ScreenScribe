import 'dart:developer';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:on_screen_ocr/main.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: const Text('ScreenScribe'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await _startService();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () async {
              await OverlayPopUp.closeOverlay();
              await _stopService();
            },
            icon: const Icon(Icons.stop),
          ),
          IconButton(
            onPressed: () async {
              showAboutDialog(
                context: context,
                applicationIcon: SizedBox(
                    height: 100,
                    width: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/icon.png'))),
                applicationName: 'ScreenScribe',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'This is a simple OCR app that uses the screenshots to capture text and copies it to clipboard.',
              );
            },
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // TextButton(
            //   onPressed: () async {
            //     final status = await OverlayPopUp.checkPermission();
            //     log("Is Permission Granted: $status");
            //   },
            //   child: const Text("Check Permission"),
            // ),
            // TextButton(
            //   onPressed: () async {
            //     final bool res = await OverlayPopUp.requestPermission();

            //     log("status: $res");
            //   },
            //   child: const Text("Request Permission"),
            // ),
            TextButton(
              onPressed: () async {
                requestNotificationsPermission();
                final bool res = await OverlayPopUp.requestPermission();

                log("status: $res");
              },
              child: const Text("Request AOT and Accessibility"),
            ),
            TextButton(
              onPressed: () async {
                await FlutterAccessibilityService.getSystemActions();
                _startService();
              },
              child: const Text("Show Overlay"),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final bool status = await FlutterAccessibilityService
            //         .isAccessibilityPermissionEnabled();
            //     if (!status) {
            //       await FlutterAccessibilityService
            //           .requestAccessibilityPermission();
            //     }
            //   },
            //   child: const Text("req accessibility"),
            // ),
            TextButton(
              onPressed: () async {
                _requestStoragePermission();
              },
              child: const Text("req storage permission"),
            ),
            TextButton(
              onPressed: () async {
                log('Try to close');
                _stopService();
                await OverlayPopUp.closeOverlay();
                // .then((value) => log('STOPPED: alue: $value'));
              },
              child: const Text("Close Overlay"),
            ),
          ],
        ),
      ),
    );
  }

  void _requestStoragePermission() async {
    openAppSettings();
  }
}
