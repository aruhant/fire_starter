import 'package:flutter/material.dart';
import 'package:fire_starter/constants/globals.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fire_starter/localizations.dart';
import 'dart:ui' as ui;

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  final language = "".obs;
  final store = GetStorage();

  String get currentLanguage => language.value;

  @override
  void onReady() async {
    setInitialLocalLanguage();
    super.onInit();
  }

  // Retrieves and Sets language based on device settings
  setInitialLocalLanguage() {
    if (currentLanguageStore.value == '') {
      String _deviceLanguage = ui.window.locale.toString();
      _deviceLanguage = _deviceLanguage.substring(0, 2); //only get 1st 2 characters
      // GetLogger.to.i(ui.window.locale.toString());
      updateLanguage(_deviceLanguage);
    }
  }

// Gets current language stored
  RxString get currentLanguageStore {
    language.value = store.read('language') ?? 'en';
    return language;
  }

  // gets the language locale app is set to
  Locale get getLocale {
    if (currentLanguageStore.value == '') {
      language.value = Globals.defaultLanguage;
      updateLanguage(Globals.defaultLanguage);
    }

    // gets the default language key (from the translation language system)
    Locale _updatedLocal = localizedLabels.keys.first;
    ;
    // looks for matching language key stored and sets to it
    localizedLabels.keys.forEach((locale) {
      if (locale.languageCode == currentLanguage) {
        _updatedLocal = locale;
      }
    });
    //print('getLocale: ' + _updatedLocal.toString());
    return _updatedLocal;
  }

// updates the language stored
  Future<void> updateLanguage(String value) async {
    language.value = value;
    await store.write('language', value);
    Get.updateLocale(getLocale);
    update();
  }
}
