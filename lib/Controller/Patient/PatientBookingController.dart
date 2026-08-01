// ignore_for_file: file_names

import 'package:get/get.dart';

import '../../core/Error/Failure.dart';
import '../../data/datasource/remote/Home/HomeData.dart';
import '../../data/model/AvailableSlotModel.dart';

class PatientBookingController extends GetxController {
  PatientBookingController(this._homeData, {required this.doctorId});

  final HomeData _homeData;
  final int doctorId;

  DateTime selectedDate = _dateOnly(DateTime.now());
  List<AvailableSlotModel> availableSlots = const [];
  AvailableSlotModel? selectedSlot;
  Failure? slotsFailure;
  Failure? bookingFailure;
  bool isLoadingSlots = false;
  bool isBooking = false;
  int? createdAppointmentId;

  @override
  void onInit() {
    super.onInit();
    loadAvailableSlots();
  }

  Future<void> selectDate(DateTime value) async {
    final date = _dateOnly(value);
    if (date == selectedDate) return;
    selectedDate = date;
    selectedSlot = null;
    await loadAvailableSlots();
  }

  Future<void> loadAvailableSlots() async {
    if (isLoadingSlots || doctorId <= 0) return;
    isLoadingSlots = true;
    slotsFailure = null;
    selectedSlot = null;
    update();

    final result = await _homeData.getAvailableSlots(
      doctorId: doctorId,
      date: selectedDate,
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        slotsFailure = failure;
        availableSlots = const [];
      },
      (slots) {
        final now = DateTime.now();
        availableSlots = slots
            .where((slot) => slot.startTime.isAfter(now))
            .toList(growable: false);
        slotsFailure = null;
      },
    );
    isLoadingSlots = false;
    update();
  }

  void selectSlot(AvailableSlotModel slot) {
    if (isBooking || !availableSlots.contains(slot)) return;
    selectedSlot = slot;
    bookingFailure = null;
    update();
  }

  Future<bool> bookSelectedSlot() async {
    final slot = selectedSlot;
    if (slot == null || isBooking) return false;
    isBooking = true;
    bookingFailure = null;
    createdAppointmentId = null;
    update();

    final result = await _homeData.createAppointment(
      doctorId: doctorId,
      appointmentDate: slot.startTime,
    );
    if (isClosed) return false;
    var succeeded = false;
    result.fold((failure) => bookingFailure = failure, (appointmentId) {
      succeeded = true;
      createdAppointmentId = appointmentId;
      bookingFailure = null;
    });
    isBooking = false;
    update();
    return succeeded;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
