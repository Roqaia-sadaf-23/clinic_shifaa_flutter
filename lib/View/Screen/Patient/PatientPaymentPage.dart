// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/Patient/HomeController.dart';
import '../../../core/Error/Failure.dart';
import '../../../core/constant/Appcolor.dart';
import '../../../core/constant/Approutes.dart';
import '../../../data/model/AppointmentModel.dart';
import '../Doctor/DoctorHomePage.dart';

class PatientPaymentPage extends StatefulWidget {
  const PatientPaymentPage({super.key});

  @override
  State<PatientPaymentPage> createState() => _PatientPaymentPageState();
}

class _PatientPaymentPageState extends State<PatientPaymentPage> {
  final _amountController = TextEditingController();
  late final PatientHomeControllerImp _controller;
  AppointmentModel? _appointment;
  bool _validArguments = false;
  bool _showMethodError = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PatientHomeControllerImp>();
    _appointment = _controller.paymentAppointment;
    _validArguments = _controller.hasPreparedPayment;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowPop,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _confirmLeavingPayment();
    },
    child: Scaffold(
      backgroundColor: DoctorHomeColors.background(context),
      appBar: AppBar(
        title: Text('paymentMethod'.tr),
        backgroundColor: DoctorHomeColors.surface(context),
        foregroundColor: DoctorHomeColors.text(context),
        elevation: 0,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _validArguments
                ? GetBuilder<PatientHomeControllerImp>(
                    builder: (controller) =>
                        _paymentBody(context, controller, _appointment!),
                  )
                : _InvalidPaymentArguments(onHome: _openPatientHome),
          ),
        ),
      ),
    ),
  );

  Widget _paymentBody(
    BuildContext context,
    PatientHomeControllerImp controller,
    AppointmentModel appointment,
  ) {
    final failure = controller.paymentFailure;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'appointmentCreated'.tr,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'selectPaymentMethod'.tr,
          style: const TextStyle(color: Appcolor.textLight),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            children: [
              _summaryRow(
                context,
                Icons.medical_services_outlined,
                'doctor'.tr,
                appointment.doctorName,
              ),
              if (appointment.doctorSpecialization?.isNotEmpty == true)
                _summaryRow(
                  context,
                  Icons.local_hospital_outlined,
                  'specialization'.tr,
                  appointment.doctorSpecialization!,
                ),
              _summaryRow(
                context,
                Icons.calendar_today_outlined,
                'appointmentDate'.tr,
                DateFormat.yMMMMd(
                  Get.locale?.languageCode,
                ).format(appointment.appointmentDate.toLocal()),
              ),
              _summaryRow(
                context,
                Icons.schedule_outlined,
                'appointmentTime'.tr,
                DateFormat.jm(
                  Get.locale?.languageCode,
                ).format(appointment.appointmentDate.toLocal()),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'totalAmount'.tr,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          enabled: !controller.isPaying,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'appointmentPrice'.tr,
            helperText: 'appointmentPriceNotProvided'.tr,
            prefixIcon: const Icon(Icons.payments_outlined),
            errorText: _amountError,
          ),
          onChanged: (_) {
            if (_amountError != null) setState(() {});
          },
        ),
        const SizedBox(height: 20),
        Text(
          'paymentMethod'.tr,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final method
            in PatientHomeControllerImp.supportedPaymentMethods) ...[
          _PaymentMethodTile(
            method: method,
            selected: controller.selectedPaymentMethod == method,
            enabled: !controller.isPaying,
            onTap: () {
              controller.selectPaymentMethod(method);
              if (_showMethodError) {
                setState(() => _showMethodError = false);
              }
            },
          ),
          const SizedBox(height: 10),
        ],
        if (_showMethodError)
          Text(
            'selectPaymentMethodValidation'.tr,
            style: const TextStyle(color: Appcolor.error),
          ),
        if (failure != null) ...[
          const SizedBox(height: 16),
          _PaymentFailureCard(failure: failure),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: controller.isPaying || controller.paymentSubmitted
                ? null
                : _submitPayment,
            icon: controller.isPaying
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Appcolor.white,
                    ),
                  )
                : const Icon(Icons.lock_outline_rounded),
            label: Text(
              controller.isPaying ? 'paymentPending'.tr : 'payNow'.tr,
            ),
          ),
        ),
      ],
    );
  }

  String? get _amountError {
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    final amount = _parsePaymentAmount(text);
    return amount != null && amount > 0
        ? null
        : 'validPaymentAmountRequired'.tr;
  }

  Future<void> _submitPayment() async {
    final amount = _parsePaymentAmount(_amountController.text);
    final invalidMethod = _controller.selectedPaymentMethod.isEmpty;
    if (invalidMethod || amount == null || amount <= 0) {
      setState(() => _showMethodError = invalidMethod);
      if (amount == null || amount <= 0) {
        Get.snackbar('paymentFailed'.tr, 'validPaymentAmountRequired'.tr);
      }
      return;
    }

    final paymentId = await _controller.submitPayment(amount: amount);
    if (!mounted || paymentId == null) return;

    try {
      await Get.offNamed<void>(
        Approutes.paymentSuccess,
        arguments: {
          'appointment': _appointment,
          'paymentId': paymentId,
          'amount': _controller.paidAmount,
          'paymentMethod': _controller.paidPaymentMethod,
        },
      );
    } catch (_) {
      if (!mounted) return;
      Get.snackbar('paymentSuccessful'.tr, 'paymentCreatedPending'.tr);
      _returnToExistingHome(tab: 2);
    }
  }

  Future<void> _confirmLeavingPayment() async {
    if (_controller.paymentSubmitted) return;
    final leave = await Get.dialog<bool>(
      AlertDialog(
        title: Text('paymentPending'.tr),
        content: Text('appointmentCreatedPaymentIncomplete'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('tryPaymentAgain'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('viewMyAppointments'.tr),
          ),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    await _controller.refreshAppointments();
    if (!mounted) return;
    setState(() => _allowPop = true);
    Get.back<void>();
    _controller.showAppointments();
  }

  void _openPatientHome() {
    _returnToExistingHome(tab: 0);
  }
}

class PatientPaymentSuccessPage extends StatelessWidget {
  const PatientPaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final map = arguments is Map ? arguments : const <Object?, Object?>{};
    final appointment = map['appointment'];
    final paymentId = map['paymentId'];
    final amount = map['amount'];
    final method = map['paymentMethod'];
    final valid =
        appointment is AppointmentModel &&
        appointment.id > 0 &&
        paymentId is num &&
        paymentId > 0 &&
        amount is num &&
        amount > 0 &&
        method is String &&
        PatientHomeControllerImp.supportedPaymentMethods.contains(method);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DoctorHomeColors.background(context),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: valid
                  ? ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        const SizedBox(height: 32),
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: Appcolor.success,
                          child: Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: Appcolor.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'paymentSuccessful'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DoctorHomeColors.text(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'paymentCreatedPending'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Appcolor.textLight),
                        ),
                        const SizedBox(height: 24),
                        SurfaceCard(
                          child: Column(
                            children: [
                              _successRow(
                                context,
                                'appointmentConfirmation'.tr,
                                '#${appointment.id}',
                              ),
                              _successRow(
                                context,
                                'doctor'.tr,
                                appointment.doctorName,
                              ),
                              _successRow(
                                context,
                                'appointmentDate'.tr,
                                DateFormat.yMMMMd(
                                  Get.locale?.languageCode,
                                ).format(appointment.appointmentDate.toLocal()),
                              ),
                              _successRow(
                                context,
                                'appointmentTime'.tr,
                                DateFormat.jm(
                                  Get.locale?.languageCode,
                                ).format(appointment.appointmentDate.toLocal()),
                              ),
                              _successRow(
                                context,
                                'totalAmount'.tr,
                                amount.toStringAsFixed(2),
                              ),
                              _successRow(
                                context,
                                'paymentMethod'.tr,
                                method.tr,
                              ),
                              _successRow(
                                context,
                                'status'.tr,
                                'paymentPending'.tr,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: () => _openHome(tab: 2),
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text('viewMyAppointments'.tr),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => _openHome(tab: 0),
                            icon: const Icon(Icons.home_outlined),
                            label: Text('returnPatientHome'.tr),
                          ),
                        ),
                      ],
                    )
                  : _InvalidPaymentArguments(onHome: () => _openHome(tab: 0)),
            ),
          ),
        ),
      ),
    );
  }

  static void _openHome({required int tab}) {
    _returnToExistingHome(tab: tab);
  }
}

void _returnToExistingHome({required int tab}) {
  if (Get.isRegistered<PatientHomeControllerImp>()) {
    final controller = Get.find<PatientHomeControllerImp>();
    if (!controller.isClosed) {
      tab == 2 ? controller.showAppointments() : controller.showHome();
      Get.until((route) => route.settings.name == Approutes.HomeScreen);
      return;
    }
  }

  Get.offAllNamed<void>(Approutes.HomeScreen, arguments: {'patientTab': tab});
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String method;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? Appcolor.gold.withValues(alpha: .12)
        : DoctorHomeColors.surface(context),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Appcolor.gold : DoctorHomeColors.border(context),
          ),
        ),
        child: Row(
          children: [
            Icon(
              method == 'Cash'
                  ? Icons.payments_outlined
                  : Icons.credit_card_outlined,
              color: selected ? Appcolor.gold : Appcolor.textLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.tr,
                style: TextStyle(
                  color: DoctorHomeColors.text(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? Appcolor.gold : Appcolor.textLight,
            ),
          ],
        ),
      ),
    ),
  );
}

class _PaymentFailureCard extends StatelessWidget {
  const _PaymentFailureCard({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      NetworkFailure() => 'networkError'.tr,
      _ when failure.statusCode == 401 => 'sessionExpired'.tr,
      _ when failure.statusCode == 409 => 'paymentAlreadyExists'.tr,
      _ when failure.statusCode == 400 =>
        '${'paymentValidationError'.tr}\n${failure.message}',
      _ when (failure.statusCode ?? 0) >= 500 => 'serverError'.tr,
      _ => failure.message,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Appcolor.error.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Appcolor.error.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'appointmentCreatedPaymentIncomplete'.tr,
            style: const TextStyle(
              color: Appcolor.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(color: DoctorHomeColors.text(context)),
          ),
          const SizedBox(height: 6),
          Text(
            'tryPaymentAgain'.tr,
            style: const TextStyle(color: Appcolor.textLight),
          ),
        ],
      ),
    );
  }
}

class _InvalidPaymentArguments extends StatelessWidget {
  const _InvalidPaymentArguments({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Appcolor.error,
            size: 52,
          ),
          const SizedBox(height: 14),
          Text(
            'invalidAppointmentInformation'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DoctorHomeColors.text(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_outlined),
            label: Text('returnPatientHome'.tr),
          ),
        ],
      ),
    ),
  );
}

Widget _summaryRow(
  BuildContext context,
  IconData icon,
  String label,
  String value, {
  bool isLast = false,
}) => Padding(
  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Appcolor.gold, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Appcolor.textLight)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: DoctorHomeColors.text(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

Widget _successRow(
  BuildContext context,
  String label,
  String value, {
  bool isLast = false,
}) => Padding(
  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: Appcolor.textLight)),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: DoctorHomeColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);

double? _parsePaymentAmount(String? input) {
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  const westernDigits = '0123456789';
  var value = input?.trim().replaceAll('٫', '.').replaceAll(',', '.') ?? '';
  for (var index = 0; index < arabicDigits.length; index++) {
    value = value.replaceAll(arabicDigits[index], westernDigits[index]);
  }
  return double.tryParse(value);
}
