import 'package:flutter/material.dart';
import 'Appcolor.dart';

ThemeData themArabic = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Appcolor.babybluecolor,
  ),

  appBarTheme: AppBarTheme(backgroundColor: Appcolor.primary),

  fontFamily: "Cairo",
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(
      fontSize: 20,
      color: Appcolor.grey,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      fontSize: 26,
      color: Appcolor.grey,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      color: Appcolor.grey,

      //fontWeight: FontWeight.bold,
    ),
  ),
);

ThemeData themEnglish = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Appcolor.babybluecolor,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    iconTheme: IconThemeData(color: Appcolor.black),
    titleTextStyle: TextStyle(
      color: Appcolor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 25,
    ),
  ),
  //fontFamily: "playfairDisplay",
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 20),
    bodyMedium: TextStyle(fontSize: 20, color: Appcolor.grey),
    bodyLarge: TextStyle(
      fontSize: 20,
      color: Appcolor.grey,
      //  fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(
      fontSize: 15,
      color: Appcolor.grey,

      //fontWeight: FontWeight.bold,
    ),
  ),
);
