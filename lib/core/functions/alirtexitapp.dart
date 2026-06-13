import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> alirtExitApp() {
  Get.defaultDialog(
    title: "Exit",
    middleText: "Are you sure you want to exit?",
    actions: [
      ElevatedButton(
        onPressed: () {
          exit(0);
        },
        child: Text("Yes"),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text("No"),
      ),
    ],
  );

  return Future.value(true); // Prevents the app from closing immediately
}
