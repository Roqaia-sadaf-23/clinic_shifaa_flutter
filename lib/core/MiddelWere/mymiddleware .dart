import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../constant/Approutes.dart';
import '../services/serveses.dart';

class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  final Myservices myservices = Get.find<Myservices>();

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

    if (!hasSession) {
      return const RouteSettings(name: Approutes.login);
    }

    switch (roleName.trim().toLowerCase()) {
      case 'doctor':
        return const RouteSettings(name: Approutes.doctorHome);

      case 'patient':
        return const RouteSettings(name: Approutes.HomeScreen);

      default:
        return const RouteSettings(name: Approutes.login);
    }
  }
}
