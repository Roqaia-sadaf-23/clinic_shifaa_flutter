import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Error/Failure.dart';

void showFailure(
  Failure failure, {
  Color? backgroundColor,
  Color? colorText,
}) {
  final title = switch (failure) {
    NetworkFailure() => 'Connection error',
    _ when failure.statusCode == 401 => 'Login failed',
    _ when failure.statusCode == 409 => 'Account already exists',
    _ when failure.statusCode == 429 => 'Too many attempts',
    _ => 'Error',
  };

  Get.snackbar(
    title,
    failure.message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: backgroundColor,
    colorText: colorText,
  );
}
