import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:on_screen_ocr/homepage.dart';
import 'package:on_screen_ocr/overlay.dart';
import 'package:on_screen_ocr/task_handler_ov.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

@pragma("vm:entry-point")
void overlayPopUp() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWidget(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: FlexThemeData.light(
        scheme: FlexScheme.deepPurple,
        surfaceMode: FlexSurfaceMode.custom,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.surface,
        appBarOpacity: 1,
        appBarElevation: 2,
        transparentStatusBar: true,
        tabBarStyle: FlexTabBarStyle.forAppBar,
        tooltipsMatchBackground: true,
        swapColors: false,
        lightIsWhite: false,
        useMaterial3: true,
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: GoogleFonts.outfit().fontFamily,
        subThemesData: const FlexSubThemesData(
          fabUseShape: true,
          appBarCenterTitle: true,
          interactionEffects: true,
          navigationBarMutedUnselectedIcon: true,
          bottomNavigationBarOpacity: 1,
          bottomNavigationBarElevation: 0,
          inputDecoratorIsFilled: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorUnfocusedHasBorder: true,
          blendOnColors: true,
          popupMenuOpacity: 0.95,
        ),
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.material,
        surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.surface,
        appBarOpacity: 1,
        appBarElevation: 2,
        transparentStatusBar: true,
        tabBarStyle: FlexTabBarStyle.flutterDefault,
        tooltipsMatchBackground: true,
        swapColors: false,
        darkIsTrueBlack: false,
        useMaterial3: true,
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: GoogleFonts.outfit().fontFamily,
        subThemesData: const FlexSubThemesData(
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarOpacity: 1,
          bottomNavigationBarElevation: 0,
          inputDecoratorIsFilled: true,
          appBarCenterTitle: true,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorUnfocusedHasBorder: true,
          blendOnColors: true,
          navigationBarMutedUnselectedIcon: true,
          popupMenuOpacity: 0.95,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
