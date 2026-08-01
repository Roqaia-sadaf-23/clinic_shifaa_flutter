import 'package:flutter/material.dart';

import '../Custome/AppProfileImage.dart';

class DoctorCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String rating;
  final String image;

  const DoctorCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.bookmark_border),
              AppProfileImage(
                imagePath: image,
                size: 70,
                backgroundColor: const Color(0xffEAF3FF),
                loadingIndicatorColor: const Color(0xff0057FF),
                fallback: const Icon(
                  Icons.medical_services_outlined,
                  size: 34,
                  color: Color(0xff0057FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            doctorName,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(specialty, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(rating),
              const SizedBox(width: 5),
              const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
