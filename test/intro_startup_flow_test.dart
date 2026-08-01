import 'package:clinic_shifaa/Controller/Intro/IntroController.dart';
import 'package:clinic_shifaa/Controller/Splash/SplashController.dart';
//import 'package:clinic_shifaa/View/Screen/IntroScreen.dart';
import 'package:clinic_shifaa/View/Screen/Splish/SplashScreen.dart';
import 'package:clinic_shifaa/core/MiddelWere/mymiddleware%20.dart';
import 'package:clinic_shifaa/core/class/AuthService.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/core/services/serveses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  testWidgets('first installation opens splash before intro', (tester) async {
    await _preparePreferences({});
    _useTallTestView(tester);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        initialRoute: Approutes.splash,
        getPages: [
          GetPage(
            name: Approutes.splash,
            page: () => const SplashScreen(),
            binding: BindingsBuilder(() {
              Get.put(
                SplashController(
                  minimumDisplayDuration: const Duration(milliseconds: 50),
                ),
              );
            }),
          ),
          GetPage(
            name: Approutes.intro,
            page: () => const Scaffold(body: Text('intro-destination')),
          ),
          GetPage(
            name: Approutes.login,
            page: () => const Scaffold(body: Text('login-destination')),
          ),
        ],
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('intro-destination'), findsOneWidget);
  });

  test('completed intro sends an unauthenticated user to login', () async {
    await _preparePreferences({AuthService.introCompletedKey: true});

    final validSession = await AuthService.prepareSessionForStartup();
    final destination = MyMiddleWare().destinationAfterInitialization(
      hasValidSession: validSession,
    );

    expect(validSession, isFalse);
    expect(destination, Approutes.login);
  });

  test('remembered patient session opens patient home', () async {
    await _preparePreferences({});
    await AuthService.saveSession(
      accessToken: 'patient-access',
      refreshToken: 'patient-refresh',
      email: 'patient@example.com',
      roleName: IntroController.patientRole,
      rememberMe: true,
    );

    final validSession = await AuthService.prepareSessionForStartup();
    final destination = MyMiddleWare().destinationAfterInitialization(
      hasValidSession: validSession,
    );

    expect(validSession, isTrue);
    expect(destination, Approutes.HomeScreen);
  });

  test('remembered doctor session opens doctor home', () async {
    await _preparePreferences({});
    await AuthService.saveSession(
      accessToken: 'doctor-access',
      refreshToken: 'doctor-refresh',
      email: 'doctor@example.com',
      roleName: IntroController.doctorRole,
      rememberMe: true,
    );

    final validSession = await AuthService.prepareSessionForStartup();
    final destination = MyMiddleWare().destinationAfterInitialization(
      hasValidSession: validSession,
    );

    expect(validSession, isTrue);
    expect(destination, Approutes.doctorHome);
  });

  testWidgets('intro blocks continue until an account type is selected', (
    tester,
  ) async {
    await _pumpIntro(tester, const Locale('en'));

    await tester.tap(find.text('Next'));
    await tester.pump();

    expect(find.text('Please select an account type.'), findsOneWidget);
    expect(await AuthService.hasCompletedIntro(), isFalse);
    //expect(find.byType(IntroScreen), findsOneWidget);
  });

  testWidgets('selected patient role is saved and passed to login', (
    tester,
  ) async {
    await _pumpIntro(tester, const Locale('en'));

    await tester.tap(find.text('Patient'));
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(await AuthService.hasCompletedIntro(), isTrue);
    expect(find.text('login-Patient'), findsOneWidget);
  });

  testWidgets('Arabic intro is localized, RTL, and passes Doctor exactly', (
    tester,
  ) async {
    await _pumpIntro(tester, const Locale('ar'));

    final title = find.text('احجز موعدك');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(find.text('المريض'), findsOneWidget);
    expect(find.text('الطبيب'), findsOneWidget);

    await tester.tap(find.text('الطبيب'));
    await tester.pump();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();

    expect(find.text('login-Doctor'), findsOneWidget);
  });
}

Future<void> _pumpIntro(WidgetTester tester, Locale locale) async {
  await _preparePreferences({});
  _useTallTestView(tester);
  Get.put(IntroController());
  /* 
  await tester.pumpWidget(
    GetMaterialApp(
      translations: MyTranslation(),
      locale: locale,
      home: const IntroScreen(),
      getPages: [
        GetPage(
          name: Approutes.login,
          page: () {
            final arguments = Get.arguments;
            final accountType = arguments is Map
                ? arguments['accountType']
                : null;
            return Scaffold(body: Text('login-$accountType'));
          },
        ),
      ],
    ),
  ); */
  await tester.pumpAndSettle();
}

Future<void> _preparePreferences(Map<String, Object> values) async {
  Get.reset();
  SharedPreferences.setMockInitialValues(values);
  await Get.putAsync<Myservices>(() => Myservices().init());
}

void _useTallTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
