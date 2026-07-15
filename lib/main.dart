import 'package:clinic_shifaa/View/Screen/Auth/Register/RegisterScreen.dart';
import 'package:clinic_shifaa/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Bindings/initialBinding.dart';
import 'View/Screen/Auth/Login/Loginpage.dart';
import 'core/localization/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/localization/changelocal.dart';
import 'core/services/serveses.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  await Get.putAsync<Myservices>(() async => await Myservices().init());

  /*  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    localController controllerlang = Get.put(localController());

    return GetMaterialApp(
      translations: MyTranslation(),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialBinding: initialBinding(),

      locale: controllerlang.languege,
      theme: controllerlang.Apptheme,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      getPages: routes,
      // theme:
      home: const LoginPage(), //DoctorDetailsPage(),
      ////SplashScreen(),
      //RegisterScreen(),
      // RegisterPage(),

      // DoctorDetailsPage(),
      //DoctorDetailsPage(), //PatientHomePage(), //AppointmentDetailsPage(), //IntroScreen(),
      //SplashScreen(),
      //Center(child: Text("data")),
      //routes: routes,.3
      // getPages: routes,
    );
  }
}
