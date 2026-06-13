import 'package:flutter/material.dart';

import '../../Widget/Doctors/DoctorsCard.dart';

class DoctorsSearchPage extends StatelessWidget {
  const DoctorsSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("البحث عن أطباء"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search
            TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن حسب الاسم أو التخصص",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🧠 Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("القريبة", true),
                _filterButton("الشائعة", false),
                _filterButton("التقييم", false),
              ],
            ),

            const SizedBox(height: 16),

            // 👨‍⚕️ Doctors List
            Expanded(
              child: ListView(
                children: const [
                  DoctorCard(
                    doctorName: "د. محمد السبيعي",
                    specialty: "استشاري قلب",
                    // location: "الرياض",
                    rating: "4.8",
                    image: '',
                  ),
                  DoctorCard(
                    doctorName: "د. سارة القحطاني",
                    specialty: "استشارية نساء وولادة",
                    //  location: "الرياض",
                    rating: "4.9",
                    image: '',
                  ),
                  DoctorCard(
                    doctorName: "د. خالد الأنصاري",
                    specialty: "استشاري عظام",
                    //location: "جدة",
                    rating: "4.7",
                    image: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }
}
/* 
// 🧑‍⚕️ Doctor Card Widget
class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String location;
  final String rating;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage("assets/doctor.png"), // 👈 add image
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialty),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                Text(location),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.orange),
            Text(rating),
          ],
        ),
      ),
    );
  }
}
 */