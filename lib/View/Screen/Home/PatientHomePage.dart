import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart';

import '../Doctor/DoctorsSearchPage .dart';
import '/View/Widget/Home/CategoryItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../Controller/Home/HomeController.dart';
import '../../Widget/Doctors/DoctorsCard.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientHomeControllerImp());

    return GetBuilder<PatientHomeControllerImp>(
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xffF7F8FC),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color.fromARGB(255, 72, 33, 243),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "الأطباء"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "مواعيدي",
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.notifications_none),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
                ],
              ),
              label: "الإشعارات",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "حسابي",
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person_outline),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            "👋 مرحباً أحمد",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "كيف يمكننا مساعدتك اليوم؟",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// Search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "ابحث عن طبيب أو تخصص",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Categories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.to(() => DoctorsSearchPage());
                        },
                        child: CategoryItem(
                          icon: Icons.grid_view_rounded,
                          title: "كل",
                          active: true,
                        ),
                      ),
                      CategoryItem(
                        icon: Icons.medical_services,
                        title: "أسنان",
                      ),
                      CategoryItem(icon: Icons.favorite, title: "قلب"),
                      CategoryItem(icon: Icons.pregnant_woman, title: "نساء"),
                      CategoryItem(icon: Icons.face, title: "جلدية"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// Title
                  const Text(
                    "أطباء مميزون",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// Doctors
                  /*   Row(
                    children: const [
                      Expanded(
                        child: DoctorCard(
                          doctorName: "د. محمد السبيعي",
                          specialty: "استشاري قلب",
                          rating: "4.8",
                          image: "https://i.pravatar.cc/300?img=12",
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: DoctorCard(
                          doctorName: "د. سارة القحطاني",
                          specialty: "أخصائية نساء وولادة",
                          rating: "4.9",
                          image: "https://i.pravatar.cc/300?img=47",
                        ),
                      ),
                    ],
                  ),
 */
                  const SizedBox(height: 30),

                  /// Appointment title
                  const Text(
                    "مواعيدك القادمة",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  /// Appointment card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/300?img=12",
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                "د. محمد السبيعي",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "الخميس، 9:00 صباحاً",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.video_call,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
