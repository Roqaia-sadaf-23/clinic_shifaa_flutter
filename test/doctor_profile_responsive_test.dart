import 'package:clinic_shifaa/View/Screen/Doctor/DoctorProfilePage.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/model/CurrentDoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  const sizes = [
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(430, 932),
  ];
  const scales = [1.0, 1.3, 1.5];

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final size in sizes) {
      for (final scale in scales) {
        testWidgets(
          'profile ${locale.languageCode} ${size.width}x${size.height} at $scale',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = size;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              GetMaterialApp(
                translations: MyTranslation(),
                locale: locale,
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const _ProfileHarness(),
                ),
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(find.text('—'), findsNWidgets(4));
          },
        );
      }
    }
  }
}

class _ProfileHarness extends StatelessWidget {
  const _ProfileHarness();

  static const doctor = CurrentDoctorModel(
    id: 14,
    personId: 41,
    firstName: 'A very long Doctor first name',
    lastName: 'A very long family name',
    age: 35,
    note: 'A professional biography that safely wraps over several lines.',
    experienceYears: 22,
    specialization: 'Dermatology and advanced skin treatment',
    imagePath: '',
    userId: 33,
  );

  @override
  Widget build(BuildContext context) {
    final metrics = DoctorProfileMetrics.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(metrics.horizontalPadding),
          child: Column(
            children: [
              AuthenticatedDoctorProfileHeader(
                doctor: doctor,
                localImagePath: null,
                isUpdatingImage: false,
                onEdit: _ignore,
                onChangePhoto: _ignore,
              ),
              SizedBox(height: metrics.sectionSpacing),
              DoctorProfileStatistics(onTap: _ignore),
              SizedBox(height: metrics.sectionSpacing),
              DoctorInformationSection(
                title: 'personalInformation'.tr,
                icon: Icons.person_outline,
                rows: const [
                  DoctorInformationRowData(
                    icon: Icons.badge_outlined,
                    label: 'Long information label',
                    value: 'Long information value that must wrap safely',
                  ),
                ],
              ),
              SizedBox(height: metrics.sectionSpacing),
              DoctorProfileActions(
                isBusy: false,
                onEdit: _ignore,
                onPhoto: _ignore,
                onLanguage: _ignore,
                onTheme: _ignore,
                onLogout: _ignore,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _ignore() {}
}
