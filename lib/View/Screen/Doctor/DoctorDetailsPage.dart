 /*/ ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Controller/Doctor/DoctorDetailsController.dart';
import '../../../core/constant/ApiLinks.dart';

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DoctorDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "تفاصيل الطبيب",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: GetBuilder<DoctorDetailsController>(
        builder: (controller) {
          //var Item = controller.doctors[0];
          if (controller.doctors == null) {
            return const Center(child: Text("++++No data+++++"));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // صورة الطبيب
                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.purple.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        right: 30,
                        top: 25,
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 55,
                          color: Colors.blue.withOpacity(0.12),
                        ),
                      ),
                      Positioned(
                        left: 35,
                        bottom: 30,
                        child: Icon(
                          Icons.favorite_border,
                          size: 55,
                          color: Colors.pink.withOpacity(0.12),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          ApiLinks.images + controller.doctors!.imagePath,

                          height: 190,
                          width: 190,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // معلومات الطبيب
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.doctors!.firstName +
                            " " +
                            controller.doctors!.lastName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.doctors!.specialization,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          const Text("4.8"),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.work_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Text("${controller.doctors!.experienceYears} سنوات خبرة"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // نبذة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "نبذة عن الطبيب",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "استشاري متخصص في أمراض القلب، لديه خبرة واسعة في تشخيص وعلاج الحالات القلبية المختلفة.",
                        textAlign: TextAlign.right,
                        style: TextStyle(height: 1.7, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
             
                // المواعيد
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "المواعيد المتاحة",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.availableDates.length,
                          itemBuilder: (context, index) {
                            final date = controller.availableDates[index];
                            final selected =
                                controller.selectedDayIndex == index;
 
                            return GestureDetector(
                              onTap: () => controller.selectDay(index),
                              child: Container(
                                width: 45, // كان أكبر
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.blue
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    "${date.day}\n${date.month}\n${date.year}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14, // تصغير الخط
                                      height: 1.5,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      /*   // الأيام
                      Row(
                        children: List.generate(
                          controller.availableDates.length,
                          (index) {
                            final isSelected =
                                controller.selectedDayIndex == index;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectDay(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : const Color(0xffF1F4F8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "${controller.availableDates[index].day}\n${controller.availableDates[index].month} ${controller.availableDates[index].year}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
 */
                      const SizedBox(height: 14),

                      /* 

                      // الأوقات
                      Row(
                        children: List.generate(
                          controller.availableTimes.length,
                          (index) {
                            final isSelected =
                                controller.selectedTimeIndex == index;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectTime(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    controller.availableTimes[index].format(
                                      context,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ), */
                      Wrap(
                        spacing: 3,
                        runSpacing: 3,
                        children: List.generate(
                          controller.availableTimes.length,
                          (index) {
                            final time = controller.availableTimes[index];
                            final selected =
                                controller.selectedTimeIndex == index;

                            return GestureDetector(
                              onTap: () => controller.selectTime(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  time.format(context),
                                  style: TextStyle(
                                    fontSize: 12, // تصغير الوقت
                                    color: selected
                                        ? Colors.white
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // زر الحجز
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.bookAppointment();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تم اختيار الموعد بنجاح")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "احجز موعد",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
 */
