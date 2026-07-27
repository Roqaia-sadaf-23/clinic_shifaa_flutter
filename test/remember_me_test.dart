import 'package:clinic_shifaa/Controller/Auth/LoginPage/LoginController.dart';
import 'package:clinic_shifaa/View/Widget/login/buildRememberAndForgot.dart';
import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/class/AuthService.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/services/serveses.dart';
import 'package:clinic_shifaa/core/MiddelWere/mymiddleware%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    // ignore: await_only_futures
    Get.reset();
  });

  test('remembered session survives startup validation', () async {
    SharedPreferences.setMockInitialValues({});

    await AuthService.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      email: 'user@example.com',
      roleName: 'Doctor',
      rememberMe: true,
    );

    expect(await AuthService.prepareSessionForStartup(), isTrue);
    expect(await AuthService.getAccessToken(), 'access-token');
    expect(await AuthService.getRefreshToken(), 'refresh-token');
    expect(await AuthService.getEmail(), 'user@example.com');
    expect(await AuthService.getRoleName(), 'Doctor');
    expect(await AuthService.isLoggedIn(), isTrue);
    expect(await AuthService.getRememberMe(), isTrue);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('password'), isFalse);
  });

  test('non-remembered session is cleared on the next startup', () async {
    SharedPreferences.setMockInitialValues({});

    await AuthService.saveSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      email: 'user@example.com',
      roleName: 'Patient',
      rememberMe: false,
    );

    expect(await AuthService.getRememberMe(), isFalse);
    expect(await AuthService.isLoggedIn(), isTrue);
    expect(await AuthService.prepareSessionForStartup(), isFalse);
    expect(await AuthService.getAccessToken(), isNull);
    expect(await AuthService.getRefreshToken(), isNull);
    expect(await AuthService.getEmail(), isNull);
    expect(await AuthService.getRoleName(), isNull);
    expect(await AuthService.isLoggedIn(), isFalse);
  });

  test('incomplete remembered session is rejected and cleared', () async {
    SharedPreferences.setMockInitialValues({
      'accessToken': 'access-token',
      'refreshToken': '',
      'email': 'user@example.com',
      'roleName': 'Doctor',
      'isLoggedIn': true,
      'rememberMe': true,
    });

    expect(await AuthService.prepareSessionForStartup(), isFalse);
    expect(await AuthService.getAccessToken(), isNull);
    expect(await AuthService.getRememberMe(), isFalse);
  });

  test(
    'middleware routes a remembered doctor session to doctor home',
    () async {
      SharedPreferences.setMockInitialValues({});
      await AuthService.saveSession(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        email: 'doctor@example.com',
        roleName: 'Doctor',
        rememberMe: true,
      );
      await Get.putAsync<Myservices>(() => Myservices().init());

      final redirect = MyMiddleWare().redirect('/');

      expect(redirect?.name, Approutes.doctorHome);
    },
  );

  testWidgets('remember me checkbox and Arabic label both toggle state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(ApiService());
    final controller = Get.put(LoginController());

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: buildRememberAndForgot())),
    );

    expect(controller.rememberMe.value, isFalse);

    await tester.tap(find.text('تذكرني'));
    await tester.pump();
    expect(controller.rememberMe.value, isTrue);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(controller.rememberMe.value, isFalse);
  });
}
