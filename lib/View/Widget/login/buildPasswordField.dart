// -------------------- حقل كلمة المرور --------------------
import 'package:clinic_shifaa/View/Widget/login/InputWrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Auth/LoginPage/LoginController.dart';
import '../../../core/constant/Appcolor.dart';

class buildPasswordField extends GetView<LoginController> {

const buildPasswordField({super.key});  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
        return InputWrapper(
          child: TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword.value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'كلمة المرور',
              hintStyle: TextStyle(color: Appcolor.subTextColor),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Appcolor.subTextColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Appcolor.subTextColor,
                ),
                onPressed: controller.toggleObscurePassword,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            validator: controller.validatePassword,
          ),
        );
    });
  }
}
