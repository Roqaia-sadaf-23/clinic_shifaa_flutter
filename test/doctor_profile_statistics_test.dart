import 'package:clinic_shifaa/View/Screen/Doctor/DoctorProfilePage.dart';
import 'package:clinic_shifaa/core/localization/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('statistics render zero values instead of dashes', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        home: Scaffold(
          body: DoctorProfileStatistics(
            appointments: 4,
            completed: 0,
            today: 0,
            patients: 0,
            onTap: _ignore,
          ),
        ),
      ),
    );

    expect(find.text('4'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('—'), findsNothing);
    expect(
      find.text(
        'Statistics will appear when a secure Doctor statistics endpoint is available.',
      ),
      findsNothing,
    );
  });

  testWidgets('statistics failure stays local to the section', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: MyTranslation(),
        locale: const Locale('en'),
        home: Scaffold(
          body: Column(
            children: [
              const Text('Doctor profile remains visible'),
              DoctorProfileStatistics(
                hasError: true,
                onTap: _ignore,
                onRetry: _ignore,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Doctor profile remains visible'), findsOneWidget);
    expect(
      find.text('The request could not be completed. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}

void _ignore() {}
