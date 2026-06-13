import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../../core/constant/Appcolor.dart';

class Custumbottunlang extends StatelessWidget {
  final void Function()? onPressed;
  final String textbutton;
  const Custumbottunlang({super.key, required this.textbutton, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Appcolor.primarycolor),
        onPressed: onPressed,
        child: Text(textbutton, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
