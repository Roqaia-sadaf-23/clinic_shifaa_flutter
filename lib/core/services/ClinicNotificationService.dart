import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/model/ClinicNotification.dart';
import '../class/AuthService.dart';
import '../constant/Approutes.dart';

class ClinicNotificationService extends GetxService {
  static const _notificationsKeyPrefix = 'clinic_notifications_v1';
  static const _snapshotsKeyPrefix = 'clinic_notification_appointments_v1';
  static const _channelId = 'clinic_appointment_reminders';
  static const _channelName = 'Appointment reminders';
  static const _channelDescription =
      'Reminders and verified clinic appointment updates';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final List<ClinicNotification> _items = [];
  final Map<int, ClinicAppointmentNotificationSnapshot> _snapshots = {};
  final Set<VoidCallback> _listeners = {};

  String? _sessionKey;
  bool _snapshotsInitialized = false;
  bool _pluginInitialized = false;
  bool _openNotificationsAfterStartup = false;

  List<ClinicNotification> get notifications {
    final visible = _items.where((item) => item.isVisible).toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return List.unmodifiable(visible);
  }

  int get unreadCount =>
      _items.where((item) => item.isVisible && !item.isRead).length;
  bool get supportsDeviceNotifications =>
      !kIsWeb &&
      {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  Future<ClinicNotificationService> init() async {
    tz_data.initializeTimeZones();
    await _initializeLocalNotifications();
    return this;
  }

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  Future<void> loadForCurrentUser({String? role}) async {
    await _ensureSession(role: role);
    _notifyListeners();
  }

  Future<bool> requestPermissions() async {
    if (!_pluginInitialized) return false;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> recordAppointmentCreated(
    ClinicAppointmentNotificationSnapshot appointment,
  ) async {
    await _ensureSession(role: 'patient');
    await _add(
      _appointmentNotification(
        id: 'patient-appointment-created-${appointment.id}',
        type: ClinicNotificationType.appointmentCreated,
        audience: 'patient',
        titleKey: 'notificationAppointmentCreatedTitle',
        bodyKey: 'notificationPatientAppointmentCreatedBody',
        appointment: appointment,
      ),
      showNow: true,
    );
    _snapshots[appointment.id] = appointment;
    _snapshotsInitialized = true;
    await _persistSnapshots();
    await _syncReminder('patient', appointment);
  }

  Future<void> recordPatientAppointmentCancelled(
    ClinicAppointmentNotificationSnapshot appointment,
  ) async {
    await _ensureSession(role: 'patient');
    await _add(
      _appointmentNotification(
        id: 'patient-appointment-cancelled-${appointment.id}',
        type: ClinicNotificationType.appointmentCancelled,
        audience: 'patient',
        titleKey: 'notificationAppointmentCancelledTitle',
        bodyKey: 'notificationPatientAppointmentCancelledBody',
        appointment: appointment,
      ),
      showNow: true,
    );
    await _cancelStaleReminders('patient', appointment.id, keepId: null);
  }

  Future<void> syncPatientAppointments(
    Iterable<ClinicAppointmentNotificationSnapshot> appointments,
  ) => _syncAppointments('patient', appointments);

  Future<void> syncDoctorAppointments(
    Iterable<ClinicAppointmentNotificationSnapshot> appointments, {
    bool detectNew = true,
  }) => _syncAppointments('doctor', appointments, detectNew: detectNew);

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
    await _persistNotifications();
    _notifyListeners();
  }

  Future<void> markAllRead() async {
    var changed = false;
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      if (!item.isVisible || item.isRead) continue;
      _items[index] = item.copyWith(isRead: true);
      changed = true;
    }
    if (!changed) return;
    await _persistNotifications();
    _notifyListeners();
  }

  Future<void> clearRead() async {
    final readIds = _items
        .where((item) => item.isRead && item.isVisible)
        .map((item) => item.id)
        .toSet();
    if (readIds.isEmpty) return;
    final removed = _items.where((item) => readIds.contains(item.id)).toList();
    _items.removeWhere((item) => readIds.contains(item.id));
    for (final item in removed) {
      await _cancelSystemNotification(item);
    }
    await _persistNotifications();
    _notifyListeners();
  }

  void openPendingNotification() {
    if (!_openNotificationsAfterStartup) return;
    _openNotificationsAfterStartup = false;
    _openNotificationsRoute();
  }

  Future<void> _syncAppointments(
    String role,
    Iterable<ClinicAppointmentNotificationSnapshot> values, {
    bool detectNew = true,
  }) async {
    await _ensureSession(role: role);
    final appointments = values.where((item) => item.id > 0).toList();
    final wasInitialized = _snapshotsInitialized;

    for (final appointment in appointments) {
      final previous = _snapshots[appointment.id];
      if (detectNew && wasInitialized && previous == null) {
        if (role == 'doctor') {
          await _add(
            _appointmentNotification(
              id: 'doctor-new-appointment-${appointment.id}',
              type: ClinicNotificationType.newAppointmentForDoctor,
              audience: role,
              titleKey: 'notificationNewAppointmentTitle',
              bodyKey: 'notificationDoctorNewAppointmentBody',
              appointment: appointment,
            ),
            showNow: true,
          );
        } else {
          await _add(
            _appointmentNotification(
              id: 'patient-appointment-created-${appointment.id}',
              type: ClinicNotificationType.appointmentCreated,
              audience: role,
              titleKey: 'notificationAppointmentCreatedTitle',
              bodyKey: 'notificationPatientAppointmentCreatedBody',
              appointment: appointment,
            ),
            showNow: true,
          );
        }
      }

      if (role == 'patient' && previous != null) {
        final oldStatus = _normalizedStatus(previous.status);
        final status = _normalizedStatus(appointment.status);
        if (status != oldStatus && status == 'confirmed') {
          await _add(
            _appointmentNotification(
              id: 'patient-appointment-confirmed-${appointment.id}',
              type: ClinicNotificationType.appointmentConfirmed,
              audience: role,
              titleKey: 'notificationAppointmentConfirmedTitle',
              bodyKey: 'notificationPatientAppointmentConfirmedBody',
              appointment: appointment,
            ),
            showNow: true,
          );
        } else if (status != oldStatus && _isCancelled(status)) {
          await recordPatientAppointmentCancelled(appointment);
        }
      }

      await _syncReminder(role, appointment);
      _snapshots[appointment.id] = appointment;
    }

    _snapshotsInitialized = true;
    await _persistSnapshots();
  }

  Future<void> _syncReminder(
    String role,
    ClinicAppointmentNotificationSnapshot appointment,
  ) async {
    final status = _normalizedStatus(appointment.status);
    final now = DateTime.now();
    if (_isCancelled(status) ||
        status == 'completed' ||
        !appointment.appointmentDate.isAfter(now)) {
      await _cancelStaleReminders(role, appointment.id, keepId: null);
      return;
    }

    final reminderId =
        '$role-appointment-reminder-${appointment.id}-'
        '${appointment.appointmentDate.millisecondsSinceEpoch}';
    await _cancelStaleReminders(role, appointment.id, keepId: reminderId);
    if (_items.any((item) => item.id == reminderId)) return;

    final desiredTime = appointment.appointmentDate.subtract(
      const Duration(hours: 24),
    );
    final reminderTime = desiredTime.isAfter(now) ? desiredTime : now;
    final notification = _appointmentNotification(
      id: reminderId,
      type: ClinicNotificationType.appointmentReminder,
      audience: role,
      titleKey: 'notificationAppointmentReminderTitle',
      bodyKey: role == 'doctor'
          ? 'notificationDoctorAppointmentReminderBody'
          : 'notificationPatientAppointmentReminderBody',
      appointment: appointment,
      createdAt: reminderTime,
      scheduledFor: reminderTime,
    );
    final added = await _add(notification, showNow: !reminderTime.isAfter(now));
    if (added && reminderTime.isAfter(now)) {
      await _scheduleSystemNotification(notification);
    }
  }

  ClinicNotification _appointmentNotification({
    required String id,
    required ClinicNotificationType type,
    required String audience,
    required String titleKey,
    required String bodyKey,
    required ClinicAppointmentNotificationSnapshot appointment,
    DateTime? createdAt,
    DateTime? scheduledFor,
  }) => ClinicNotification(
    id: id,
    type: type,
    audience: audience,
    titleKey: titleKey,
    bodyKey: bodyKey,
    parameters: {
      'name': appointment.personName.trim().isEmpty
          ? 'notificationUnknownPerson'.tr
          : appointment.personName.trim(),
      'date': _formatDate(appointment.appointmentDate),
    },
    createdAt:
        createdAt ?? appointment.lastStatusDate?.toLocal() ?? DateTime.now(),
    appointmentId: appointment.id,
    scheduledFor: scheduledFor,
  );

  Future<bool> _add(
    ClinicNotification notification, {
    required bool showNow,
  }) async {
    if (_items.any((item) => item.id == notification.id)) return false;
    _items.add(notification);
    _trimOldNotifications();
    await _persistNotifications();
    _notifyListeners();
    if (showNow) await _showSystemNotification(notification);
    return true;
  }

  Future<void> _cancelStaleReminders(
    String role,
    int appointmentId, {
    required String? keepId,
  }) async {
    final stale = _items
        .where(
          (item) =>
              item.audience == role &&
              item.appointmentId == appointmentId &&
              item.type == ClinicNotificationType.appointmentReminder &&
              item.id != keepId &&
              !item.isVisible,
        )
        .toList();
    if (stale.isEmpty) return;
    _items.removeWhere((item) => stale.any((value) => value.id == item.id));
    for (final item in stale) {
      await _cancelSystemNotification(item);
    }
    await _persistNotifications();
    _notifyListeners();
  }

  Future<void> _ensureSession({String? role}) async {
    final email = (await AuthService.getEmail())?.trim().toLowerCase();
    final sessionRole =
        role?.trim().toLowerCase() ??
        (await AuthService.getRoleName())?.trim().toLowerCase() ??
        'unknown';
    final nextKey = '$sessionRole::${email ?? 'anonymous'}';
    if (_sessionKey == nextKey) return;
    _sessionKey = nextKey;
    _items.clear();
    _snapshots.clear();
    _snapshotsInitialized = false;

    final prefs = await SharedPreferences.getInstance();
    final rawNotifications = prefs.getString(_notificationsStorageKey);
    if (rawNotifications != null) {
      try {
        final decoded = jsonDecode(rawNotifications);
        if (decoded is List) {
          _items.addAll(
            decoded.whereType<Map>().map(
              (item) =>
                  ClinicNotification.fromJson(Map<String, dynamic>.from(item)),
            ),
          );
        }
      } catch (_) {
        _items.clear();
      }
    }

    final rawSnapshots = prefs.getString(_snapshotsStorageKey);
    if (rawSnapshots != null) {
      try {
        final decoded = jsonDecode(rawSnapshots);
        if (decoded is Map) {
          _snapshotsInitialized = decoded['initialized'] == true;
          final rawItems = decoded['items'];
          if (rawItems is List) {
            for (final item in rawItems.whereType<Map>()) {
              final snapshot = ClinicAppointmentNotificationSnapshot.fromJson(
                Map<String, dynamic>.from(item),
              );
              if (snapshot.id > 0) _snapshots[snapshot.id] = snapshot;
            }
          }
        }
      } catch (_) {
        _snapshots.clear();
        _snapshotsInitialized = false;
      }
    }
  }

  Future<void> _persistNotifications() async {
    if (_sessionKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsStorageKey,
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _persistSnapshots() async {
    if (_sessionKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _snapshotsStorageKey,
      jsonEncode({
        'initialized': _snapshotsInitialized,
        'items': _snapshots.values.map((item) => item.toJson()).toList(),
      }),
    );
  }

  String get _notificationsStorageKey =>
      '$_notificationsKeyPrefix::${_sessionKey!}';
  String get _snapshotsStorageKey => '$_snapshotsKeyPrefix::${_sessionKey!}';

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb ||
        !{
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        }.contains(defaultTargetPlatform)) {
      return;
    }
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      _pluginInitialized =
          await _plugin.initialize(
            settings: settings,
            onDidReceiveNotificationResponse: (_) => _openNotificationsRoute(),
          ) ??
          false;
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      _openNotificationsAfterStartup =
          launchDetails?.didNotificationLaunchApp == true;
    } catch (_) {
      _pluginInitialized = false;
    }
  }

  Future<void> _showSystemNotification(ClinicNotification notification) async {
    if (!_pluginInitialized) return;
    try {
      await _plugin.show(
        id: _platformId(notification.id),
        title: notification.titleKey.trParams(notification.parameters),
        body: notification.bodyKey.trParams(notification.parameters),
        notificationDetails: _notificationDetails,
        payload: notification.id,
      );
    } catch (_) {
      // The persisted in-app notification remains available when OS delivery
      // is disabled or unsupported.
    }
  }

  Future<void> _scheduleSystemNotification(
    ClinicNotification notification,
  ) async {
    final scheduledFor = notification.scheduledFor;
    if (!_pluginInitialized || scheduledFor == null) return;
    try {
      await _plugin.zonedSchedule(
        id: _platformId(notification.id),
        title: notification.titleKey.trParams(notification.parameters),
        body: notification.bodyKey.trParams(notification.parameters),
        scheduledDate: tz.TZDateTime.from(scheduledFor.toUtc(), tz.UTC),
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notification.id,
      );
    } catch (_) {
      // The reminder still appears in the in-app list when the app is opened.
    }
  }

  Future<void> _cancelSystemNotification(
    ClinicNotification notification,
  ) async {
    if (!_pluginInitialized) return;
    try {
      await _plugin.cancel(id: _platformId(notification.id));
    } catch (_) {}
  }

  NotificationDetails get _notificationDetails => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
    macOS: DarwinNotificationDetails(),
  );

  void _openNotificationsRoute() {
    if (Get.currentRoute == Approutes.Notvications) return;
    Get.toNamed<void>(Approutes.Notvications);
  }

  void _trimOldNotifications() {
    if (_items.length <= 200) return;
    _items.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    _items.removeRange(200, _items.length);
  }

  void _notifyListeners() {
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  String _formatDate(DateTime value) {
    final locale = Get.locale?.languageCode ?? 'en';
    final local = value.toLocal();
    try {
      return DateFormat.yMMMd(locale).add_jm().format(local);
    } catch (_) {
      final date =
          '${local.year.toString().padLeft(4, '0')}-'
          '${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
      final time =
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
      return '$date $time';
    }
  }

  String _normalizedStatus(String value) => value.trim().toLowerCase();
  bool _isCancelled(String status) =>
      status == 'cancelled' || status == 'canceled';

  int _platformId(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
