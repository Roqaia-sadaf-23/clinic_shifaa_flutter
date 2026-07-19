import 'package:clinic_shifaa/View/Screen/Doctor/DoctorHomePage.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:clinic_shifaa/data/model/CurrentDoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(430, 932),
  ];
  const scales = <double>[1, 1.3, 1.5];

  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final size in sizes) {
      for (final scale in scales) {
        testWidgets(
          '${locale.languageCode} ${size.width}x${size.height} scale $scale has no overflow',
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
                  child: const _DoctorHomeHarness(),
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

class _DoctorHomeHarness extends StatelessWidget {
  const _DoctorHomeHarness();

  static const doctor = CurrentDoctorModel(
    id: 14,
    personId: 41,
    firstName: 'A very long Doctor first name',
    lastName: 'A very long family name',
    age: 35,
    note: 'Short professional note.',
    experienceYears: 22,
    specialization: 'Dermatology and advanced skin treatment',
    imagePath: '',
    userId: 33,
  );

  @override
  Widget build(BuildContext context) {
    final layout = DoctorHomeLayout.of(context);
    return Scaffold(
      backgroundColor: DoctorHomeColors.background(context),
      bottomNavigationBar: DoctorBottomNavigation(
        currentIndex: 0,
        onTap: (_) {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            layout.horizontalPadding,
            18,
            layout.horizontalPadding,
            DoctorHomeLayout.navigationHeight +
                MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            children: [
              DoctorProfileHeader(doctor: doctor, onAction: _ignore),
              const SizedBox(height: 20),
              DoctorActionGrid(onAction: _ignoreIndex),
              const SizedBox(height: 28),
              const AppointmentSummaryRow(),
              const SizedBox(height: 28),
              TodayAppointmentsSection(onViewAll: _ignore),
              const SizedBox(height: 24),
              AllAppointmentsPreview(onViewAll: _ignore),
            ],
          ),
        ),
      ),
    );
  }

  static void _ignore() {}
  static void _ignoreIndex(int _) {}
}
