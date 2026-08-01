import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../class/AuthService.dart';
import '../constant/Approutes.dart';
import '../services/serveses.dart';

class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  final Myservices myservices = Get.find<Myservices>();

  String destinationAfterInitialization({required bool hasValidSession}) {
    final preferences = myservices.sharedPreferences;

    if (hasValidSession) {
      final roleName = preferences?.getString('roleName')?.trim().toLowerCase();
      return switch (roleName) {
        'doctor' => Approutes.doctorHome,
        'patient' => Approutes.HomeScreen,
        _ => Approutes.login,
      };
    }

    final introCompleted =
        preferences?.getBool(AuthService.introCompletedKey) ?? false;
    return introCompleted ? Approutes.login : Approutes.intro;
  }

  @override
  RouteSettings? redirect(String? route) {
    final preferences = myservices.sharedPreferences;

    final rememberMe = preferences?.getBool('rememberMe') ?? false;

    final isLoggedIn = preferences?.getBool('isLoggedIn') ?? false;

    final accessToken = preferences?.getString('accessToken');

    final refreshToken = preferences?.getString('refreshToken');

    final roleName = preferences?.getString('roleName');

    final hasSession =
        rememberMe &&
        isLoggedIn &&
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty &&
        roleName != null &&
        roleName.trim().isNotEmpty;

    return RouteSettings(
      name: destinationAfterInitialization(hasValidSession: hasSession),
    );
  }
}
