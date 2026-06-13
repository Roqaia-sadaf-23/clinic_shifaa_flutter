import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constant/Appcolor.dart';

class Custombuttonappbar extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final IconData iconData;
  final bool active;

  const Custombuttonappbar({
    super.key,
    required this.onPressed,
    required this.text,
    required this.iconData,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: active == true ? Appcolor.primarycolor : Colors.black,
          ),
          Text(
            text,
            style: TextStyle(
              color: active == true ? Appcolor.primarycolor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
