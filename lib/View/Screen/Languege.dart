import '../Widget/languege/Custumbottunlang.dart';
import '../../core/constant/Approutes.dart';
import '../../core/localization/changelocal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Languege extends GetView<localController> {
  const Languege({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              // width: double.infinity,
              child: Text(
                '1'.tr,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 20),
            Custumbottunlang(
              textbutton: "English",
              onPressed: () {
                // Add your logic to change the language to English
                controller.changeLang("en");
                Get.offNamed("/OnBoarding");
              },
            ),
            const SizedBox(height: 10),
            Custumbottunlang(
              textbutton: "العربية",
              onPressed: () {
                // Add your logic to change the language to Arabic
                controller.changeLang("ar");
                Get.offNamed(Approutes.OnBoarding);
              },
            ),
          ],
        ),
      ),
    );
  }
}
