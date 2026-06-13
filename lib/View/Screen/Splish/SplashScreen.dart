import 'package:flutter/material.dart';

import '../../../core/constant/Appimagesassent.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 440,
                height: 440,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Appimagesassent.logo),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App Name
              const Text(
                "صحتك",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0B2C6B),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "نحن نهتم بصحتك",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff1E3A70),
                ),
              ),

              const SizedBox(height: 120),

              // Loading Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: 0.7,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xff214FC6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
