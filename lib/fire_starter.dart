library firestarter;

import 'dart:async';
import 'package:fire_starter/controllers/controllers.dart';
import 'package:fire_starter/models/metadata_model.dart';
import 'package:fire_starter/services/auth_service.dart';
import 'package:fire_starter/services/database_service.dart';
import 'package:fire_starter/services/notification.dart';
import 'package:fire_starter/services/package_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

/// FireFlutter
///
/// Recommendation: instantiate `FireFlutter` class into a global variable
/// and use it all over the app runtime.
///
/// Warning: instantiate it after `initFirebase`. One of good places is insdie
/// the first widget loaded by `runApp()` or home screen.
class FireStarter {
  static Map<String, Map> settings = {};

  /// [socialLoginHandler] will be invoked when a social login success or fail.
  FireStarter() {
    // print('FireFlutter');
  }

  Future<void> init({
    // String firebaseServerToken,
    required Map<String, Map<dynamic, dynamic>> settings,
    // Map<String, Map<String, String>> translations,
  }) async {
    FireStarter.settings = settings;
    WidgetsFlutterBinding.ensureInitialized();
    Get.put<Logger>(Logger(
      printer: PrettyPrinter(
          noBoxingByDefault: true,
          methodCount: 0, // number of method calls to be displayed
          errorMethodCount: 8, // number of method calls if stacktrace is provided
          lineLength: 120, // width of the output
          colors: true, // Colorful log messages
          printEmojis: true, // Print an emoji for each log message
          printTime: false // Should each log print contain a timestamp
          ),
    ));
    await Firebase.initializeApp();
    await GetStorage.init();
    await PackageInfoService.init();
    Get.put<LanguageController>(LanguageController());
    Get.put<ThemeController>(ThemeController());
    Get.put<AuthService>(AuthService());
    Get.put<DatabaseService>(DatabaseService());
    Get.put<NotificationService>(NotificationService());
    MetadataModel.init();
    ThemeController themeController = ThemeController.to;
    if (false && kDebugMode && themeIndex == -1)
      Timer.periodic(const Duration(seconds: 15), (Timer timer) {
        themeIndex = (themeIndex + 7) % FlexScheme.values.length;
        themeController.setTheme(FlexScheme.values[themeIndex].toString().split('.')[1]);
        if (themeIndex % 4 == 0) themeController.setThemeMode(themeController.isDarkModeOn ? 'light' : 'dark');
      });

    if (!kDebugMode && themeIndex == -1) {
      themeIndex = DateTime.now().millisecondsSinceEpoch % FlexScheme.values.length;
      themeController.setTheme(FlexScheme.values[themeIndex].toString().split('.')[1]);
    }
    // LanguageController languageController = LanguageController.to;
    // Timer.periodic(const Duration(seconds: 13), (Timer timer) {
    //   return languageController.updateLanguage(languageController.currentLanguage == 'en' ? 'hi' : 'en');
    // });
  }

  static int themeIndex = -1;
}
