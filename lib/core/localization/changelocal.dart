import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '/core/services/serveses.dart';
import '/core/constant/AppTheme.dart';

class localController extends GetxController {
  Locale? languege;
  ThemeData Apptheme = themEnglish;

  Myservices myservices = Get.find<Myservices>();

  changeLang(String langcode) {
    Locale locale = Locale(langcode);
    myservices.sharedPreferences?.setString("lang", langcode);
    Apptheme = langcode == "ar" ? themArabic : themEnglish;
    Get.changeTheme(Apptheme);
    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    myservices = Get.find<Myservices>();
    super.onInit();

    String? sharedpreflang = myservices.sharedPreferences?.getString("lang");
    if (sharedpreflang == "ar") {
      languege = const Locale("ar");
      Apptheme = themArabic;
    } else if (sharedpreflang == "en") {
      languege = const Locale("en");
      Apptheme = themEnglish;
    } else {
      languege = Locale(Get.deviceLocale?.languageCode ?? "en");
      Apptheme = themEnglish;
    }
    // super.onInit();
  }
}
