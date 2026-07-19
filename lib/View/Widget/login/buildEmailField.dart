import 'package:clinic_shifaa/View/Widget/login/InputWrapper.dart';
import 'package:flutter/material.dart';

import '../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../core/constant/Appcolor.dart';

Widget buildEmailField(LoginController controller) {
  return InputWrapper(
    child: TextFormField(
      controller: controller.loginController,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Email or Username',
        hintStyle: TextStyle(color: Appcolor.subTextColor),
        prefixIcon: Icon(Icons.email_outlined, color: Appcolor.subTextColor),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      validator: controller.validateLogin,
    ),
  );
}
