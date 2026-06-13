import 'package:clinic_shifaa/View/Widget/Doctors/DoctorHeader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../Controller/Doctor/DoctorHome_Controller.dart';
import '../../Widget/Doctors/DoctorStats.dart';

class AppointmentModel {
  final String name;
  final String type;
  final String time;
  final String status;
  final Color statusColor;
  final Color textColor;

  const AppointmentModel({
    required this.name,
    required this.type,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.textColor,
  });
}

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DoctorController());

    return GetBuilder<DoctorController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xffF4F7FB),

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xff0D6EFD),
            shape: const CircleBorder(),
            onPressed: () {},
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ).animate().scale(duration: 500.ms),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: const DoctorBottomNav(),

          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DoctorHeader()
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: -0.2),

                        const SizedBox(height: 26),

                        const DoctorStats()
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 28),

                        const Text(
                          "مواعيد اليوم",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(delay: 250.ms),

                        const SizedBox(height: 14),

                        ...List.generate(controller.appointments.length, (
                          index,
                        ) {
                          final item = controller.appointments[index];

                          return AppointmentTile(
                                name: item.name,
                                type: item.type,
                                time: item.time,
                                status: item.status,
                                statusColor: item.statusColor,
                                textColor: item.textColor,
                              )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: (index * 120).ms)
                              .slideY(begin: 0.25);
                        }),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class AppointmentTile extends StatelessWidget {
  final String name;
  final String type;
  final String time;
  final String status;
  final Color statusColor;
  final Color textColor;

  const AppointmentTile({
    super.key,
    required this.name,
    required this.type,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  type,
                  style: const TextStyle(
                    color: Color(0xff8A8A8A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorBottomNav extends StatelessWidget {
  const DoctorBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 12,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            NavItem(icon: Icons.home_rounded, label: "الرئيسية", active: true),
            NavItem(icon: Icons.search_rounded, label: "البحث"),
            SizedBox(width: 45),
            NavItem(icon: Icons.calendar_today_rounded, label: "المواعيد"),
            NavItem(icon: Icons.person_rounded, label: "حسابي"),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xff0D6EFD) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? const Color(0xff0D6EFD) : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
