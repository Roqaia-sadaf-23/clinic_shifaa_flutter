import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: active ? Colors.blue : Colors.grey.shade200,
          child: Icon(icon, color: active ? Colors.white : Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}
