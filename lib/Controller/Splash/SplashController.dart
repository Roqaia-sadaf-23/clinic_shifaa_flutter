// ignore_for_file: file_names

import 'package:get/get.dart';

import '../../core/MiddelWere/mymiddleware%20.dart';
import '../../core/class/AuthService.dart';

class SplashController extends GetxController {
  SplashController({
    this.minimumDisplayDuration = const Duration(milliseconds: 800),
  });

  final Duration minimumDisplayDuration;
  bool _started = false;

  @override
  void onReady() {
    super.onReady();
    initialize();
  }

  Future<void> initialize() async {
    if (_started) return;
    _started = true;

    final sessionFuture = AuthService.prepareSessionForStartup();
    await Future<void>.delayed(minimumDisplayDuration);
    final hasValidSession = await sessionFuture;
    if (isClosed) return;

    final destination = MyMiddleWare().destinationAfterInitialization(
      hasValidSession: hasValidSession,
    );
    Get.offAllNamed<void>(destination);
  }
}
