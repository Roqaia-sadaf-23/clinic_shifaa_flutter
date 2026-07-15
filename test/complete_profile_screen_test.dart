import 'package:clinic_shifaa/Bindings/CompleteProfileBinding.dart';
import 'package:clinic_shifaa/View/Screen/CompleteProfile/CompleteProfileScreen.dart';
import 'package:clinic_shifaa/core/constant/Approutes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Complete Profile opens through its bound route', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Approutes.completeProfile,
        getPages: [
          GetPage(
            name: Approutes.completeProfile,
            page: () => const CompleteProfileScreen(),
            binding: CompleteProfileBinding(),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Complete Profile'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
  });
}
