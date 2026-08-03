import 'package:clinic_shifaa/core/services/ClinicNotificationService.dart';
import 'package:clinic_shifaa/data/model/ClinicNotification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'email': 'patient@example.com',
      'roleName': 'Patient',
    });
  });

  test(
    'created appointment notification is persisted and deduplicated',
    () async {
      final service = ClinicNotificationService();
      final appointment = _snapshot(id: 31, status: 'Pending');

      await service.recordAppointmentCreated(appointment);
      await service.recordAppointmentCreated(appointment);

      expect(service.notifications, hasLength(1));
      expect(
        service.notifications.single.type,
        ClinicNotificationType.appointmentCreated,
      );
      expect(service.unreadCount, 1);

      final reloaded = ClinicNotificationService();
      await reloaded.loadForCurrentUser(role: 'patient');
      expect(reloaded.notifications, hasLength(1));
      expect(reloaded.notifications.single.appointmentId, 31);
    },
  );

  test(
    'patient status transition creates one confirmed notification',
    () async {
      final service = ClinicNotificationService();
      await service.syncPatientAppointments([
        _snapshot(id: 7, status: 'Pending'),
      ]);

      await service.syncPatientAppointments([
        _snapshot(id: 7, status: 'Confirmed', changedNow: true),
      ]);
      await service.syncPatientAppointments([
        _snapshot(id: 7, status: 'Confirmed', changedNow: true),
      ]);

      final confirmed = service.notifications.where(
        (item) => item.type == ClinicNotificationType.appointmentConfirmed,
      );
      expect(confirmed, hasLength(1));
    },
  );

  test('doctor baseline does not notify historical appointments', () async {
    SharedPreferences.setMockInitialValues({
      'email': 'doctor@example.com',
      'roleName': 'Doctor',
    });
    final service = ClinicNotificationService();
    await service.syncDoctorAppointments([_snapshot(id: 1, status: 'Pending')]);
    expect(
      service.notifications.where(
        (item) => item.type == ClinicNotificationType.newAppointmentForDoctor,
      ),
      isEmpty,
    );

    await service.syncDoctorAppointments([
      _snapshot(id: 1, status: 'Pending'),
      _snapshot(id: 2, status: 'Pending'),
    ]);
    final newAppointments = service.notifications.where(
      (item) => item.type == ClinicNotificationType.newAppointmentForDoctor,
    );
    expect(newAppointments, hasLength(1));
    expect(newAppointments.single.appointmentId, 2);
  });

  test('near appointment produces a visible reminder only once', () async {
    final service = ClinicNotificationService();
    final appointment = ClinicAppointmentNotificationSnapshot(
      id: 11,
      personName: 'Doctor Name',
      appointmentDate: DateTime.now().add(const Duration(hours: 2)),
      status: 'Pending',
    );

    await service.syncPatientAppointments([appointment]);
    await service.syncPatientAppointments([appointment]);

    final reminders = service.notifications.where(
      (item) => item.type == ClinicNotificationType.appointmentReminder,
    );
    expect(reminders, hasLength(1));
  });
}

ClinicAppointmentNotificationSnapshot _snapshot({
  required int id,
  required String status,
  bool changedNow = false,
}) => ClinicAppointmentNotificationSnapshot(
  id: id,
  personName: 'Person $id',
  appointmentDate: DateTime.now().add(const Duration(days: 3)),
  status: status,
  lastStatusDate: changedNow ? DateTime.now() : null,
);
