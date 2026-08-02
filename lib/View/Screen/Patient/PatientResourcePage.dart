// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Patient/HomeController.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../data/datasource/remote/Home/HomeData.dart';
import '../Doctor/DoctorHomePage.dart';

class PatientResourcePage extends StatefulWidget {
  const PatientResourcePage({super.key});

  @override
  State<PatientResourcePage> createState() => _PatientResourcePageState();
}

class _PatientResourcePageState extends State<PatientResourcePage> {
  PatientResourceType? _type;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<PatientHomeControllerImp>();
    _type = controller.resourceFromArguments(Get.arguments);
    if (_type != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.loadResource(_type!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    return GetBuilder<PatientHomeControllerImp>(
      builder: (controller) => Scaffold(
        backgroundColor: DoctorHomeColors.background(context),
        appBar: AppBar(title: Text(_title(type))),
        body: type == null
            ? Center(child: Text('resourceUnavailable'.tr))
            : _body(context, controller, type),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    PatientHomeControllerImp controller,
    PatientResourceType type,
  ) {
    final loading = controller.loadingResources.contains(type);
    final failure = controller.resourceFailures[type];
    final items = controller.resourceItems[type];
    if (loading && items == null) {
      return const Center(
        child: CircularProgressIndicator(color: Appcolor.gold),
      );
    }
    if (failure != null && items == null) {
      return DoctorEmptyState(
        message: _errorKey(type).tr,
        onRetry: () => controller.loadResource(type, force: true),
      );
    }
    if (items == null || items.isEmpty) {
      return DoctorEmptyState(
        message: _emptyKey(type).tr,
        onRetry: () => controller.loadResource(type, force: true),
      );
    }
    return RefreshIndicator(
      color: Appcolor.gold,
      onRefresh: () => controller.loadResource(type, force: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _PatientResourceCard(type: type, item: items[index]),
      ),
    );
  }

  String _title(PatientResourceType? type) => switch (type) {
    PatientResourceType.medicalRecords => 'medicalRecords'.tr,
    PatientResourceType.prescriptions => 'prescriptions'.tr,
    PatientResourceType.payments => 'payments'.tr,
    null => 'patientHome'.tr,
  };

  String _emptyKey(PatientResourceType type) => switch (type) {
    PatientResourceType.medicalRecords => 'noMedicalRecords',
    PatientResourceType.prescriptions => 'noPrescriptions',
    PatientResourceType.payments => 'noPayments',
  };

  String _errorKey(PatientResourceType type) => switch (type) {
    PatientResourceType.medicalRecords => 'medicalRecordsLoadError',
    PatientResourceType.prescriptions => 'prescriptionsLoadError',
    PatientResourceType.payments => 'patientPaymentHistoryUnavailable',
  };
}

class _PatientResourceCard extends StatelessWidget {
  const _PatientResourceCard({required this.type, required this.item});

  final PatientResourceType type;
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final rows = _rows(context);
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Appcolor.gold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_icon, color: Appcolor.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rows.isEmpty ? _fallbackTitle : rows.first.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DoctorHomeColors.text(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          for (final row in rows.skip(1)) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 112,
                  child: Text(
                    row.$1,
                    style: const TextStyle(color: Appcolor.textLight),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.$2,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: DoctorHomeColors.text(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<(String, String)> _rows(BuildContext context) {
    final rows = <(String, String)>[];
    void add(String key, List<String> names, {bool date = false}) {
      final value = _value(names);
      if (value == null) return;
      final display = date ? _date(value) : value.toString().trim();
      if (display.isNotEmpty) rows.add((key.tr, display));
    }

    void addLocalized(
      String key,
      List<String> names, {
      bool lowerCase = false,
    }) {
      final value = _value(names)?.toString().trim();
      if (value == null || value.isEmpty) return;
      rows.add((key.tr, (lowerCase ? value.toLowerCase() : value).tr));
    }

    switch (type) {
      case PatientResourceType.medicalRecords:
        add('diagnosis', const ['diagnosis']);
        add('visitDescription', const ['visitDescription']);
        add('appointmentDate', const [
          'appointmentDate',
          'createdAt',
        ], date: true);
        add('notes', const ['notes']);
      case PatientResourceType.prescriptions:
        add('medicationName', const ['medicationName']);
        add('dosage', const ['dosage']);
        add('frequency', const ['frequency']);
        add('specialInstructions', const ['specialInstructions']);
      case PatientResourceType.payments:
        add('amount', const ['amount']);
        addLocalized('paymentMethod', const ['paymentMethod']);
        addLocalized('status', const ['status'], lowerCase: true);
        add('createdDate', const ['createdAt', 'createdDate'], date: true);
    }
    return rows;
  }

  Object? _value(List<String> names) {
    for (final entry in item.entries) {
      if (names.any((name) => entry.key.toLowerCase() == name.toLowerCase())) {
        final value = entry.value;
        if (value != null && value.toString().trim().isNotEmpty) return value;
      }
    }
    return null;
  }

  String _date(Object value) {
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return DateFormat.yMMMd(Get.locale?.languageCode).format(parsed.toLocal());
  }

  IconData get _icon => switch (type) {
    PatientResourceType.medicalRecords => Icons.folder_shared_outlined,
    PatientResourceType.prescriptions => Icons.medication_outlined,
    PatientResourceType.payments => Icons.payments_outlined,
  };

  String get _fallbackTitle => switch (type) {
    PatientResourceType.medicalRecords => 'medicalRecords'.tr,
    PatientResourceType.prescriptions => 'prescriptions'.tr,
    PatientResourceType.payments => 'payments'.tr,
  };
}
