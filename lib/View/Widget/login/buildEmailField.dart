// -------------------- حقل البريد الإلكتروني --------------------
import 'package:clinic_shifaa/View/Widget/login/InputWrapper.dart';
import 'package:clinic_shifaa/View/Widget/login/buildTitle.dart';
import 'package:flutter/material.dart';

import '../../../core/constant/Appcolor.dart';

Widget buildEmailField(dynamic controller) {
  return InputWrapper(
    child: TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'البريد الإلكتروني',
        hintStyle: TextStyle(color: Appcolor.subTextColor),
        prefixIcon: Icon(Icons.email_outlined, color: Appcolor.subTextColor),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
      validator: controller.validateEmail,
    ),
  );
}
