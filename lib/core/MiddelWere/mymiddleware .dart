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

    final isLoggedIn = preferences?.getBool('isLoggedIn') ?? false;

    final accessToken = preferences?.getString('accessToken');

    final refreshToken = preferences?.getString('refreshToken');

    final roleName = preferences?.getString('roleName');

    final hasSession =
        isLoggedIn &&
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    if (!hasSession) {
      return const RouteSettings(name: Approutes.login);
    }

    switch (roleName?.toLowerCase()) {
      case 'doctor':
        return const RouteSettings(name: Approutes.doctorHome);

      case 'patient':
        return const RouteSettings(name: Approutes.HomeScreen);

      default:
        return const RouteSettings(name: Approutes.login);
    }
  }
}
