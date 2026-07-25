import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Doctor/DoctorPatientsController.dart';
import '../../../core/constant/ApiLinks.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../data/model/DoctorPatientModel.dart';
import 'DoctorHomePage.dart';

class DoctorPatientsPage extends StatelessWidget {
  const DoctorPatientsPage({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<DoctorPatientsController>(
    builder: (controller) {
      if (controller.isLoading && controller.patients.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.failure != null && controller.patients.isEmpty) {
        return DoctorEmptyState(
          message: 'patientsLoadError'.tr,
          onRetry: controller.load,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshPatients,
        child: controller.patients.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * .25),
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 54,
                    color: Appcolor.info,
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text('noPatients'.tr)),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                itemCount: controller.patients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) =>
                    _PatientCard(patient: controller.patients[index]),
              ),
      );
    },
  );
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient});
  final DoctorPatientModel patient;

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      '${'bloodType'.tr}: ${patient.bloodType ?? 'notProvided'.tr}',
      '${'appointmentCount'.tr}: ${patient.appointmentsCount}',
      if (patient.lastAppointmentDate != null)
        '${'lastAppointment'.tr}: ${DateFormat.yMd(Get.locale?.languageCode).format(patient.lastAppointmentDate!.toLocal())}',
    ];
    final image = patient.patientImage;
    final url = image == null
        ? null
        : image.startsWith('http')
        ? image
        : '${ApiLinks.images}$image';
    return Card(
      color: DoctorHomeColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PatientImage(url: url),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  for (final detail in details) ...[
                    const SizedBox(height: 4),
                    Text(detail, style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientImage extends StatelessWidget {
  const _PatientImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      color: Appcolor.accent.withValues(alpha: .12),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, color: Appcolor.accent),
    );
    if (url == null) return ClipOval(child: placeholder);
    return ClipOval(
      child: Image.network(
        url!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}
