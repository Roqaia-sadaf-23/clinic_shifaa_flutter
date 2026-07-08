import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Auth/LoginPage/LoginController.dart';

class handleLogin extends GetView<LoginController> {
  const handleLogin(BuildContext context, {super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.submit()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('جاري تسجيل الدخول...')));
    }
    return const SizedBox();
  }
}
