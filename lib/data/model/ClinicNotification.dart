enum ClinicNotificationType {
  appointmentCreated,
  appointmentConfirmed,
  appointmentCancelled,
  appointmentReminder,
  paymentCompleted,
  medicalRecordCreated,
  prescriptionCreated,
  newAppointmentForDoctor,
}

class ClinicNotification {
  const ClinicNotification({
    required this.id,
    required this.type,
    required this.audience,
    required this.titleKey,
    required this.bodyKey,
    required this.createdAt,
    this.parameters = const {},
    this.appointmentId,
    this.isRead = false,
    this.scheduledFor,
  });

  final String id;
  final ClinicNotificationType type;
  final String audience;
  final String titleKey;
  final String bodyKey;
  final Map<String, String> parameters;
  final DateTime createdAt;
  final int? appointmentId;
  final bool isRead;
  final DateTime? scheduledFor;

  bool get isVisible => !createdAt.isAfter(DateTime.now());

  ClinicNotification copyWith({bool? isRead}) => ClinicNotification(
    id: id,
    type: type,
    audience: audience,
    titleKey: titleKey,
    bodyKey: bodyKey,
    parameters: parameters,
    createdAt: createdAt,
    appointmentId: appointmentId,
    isRead: isRead ?? this.isRead,
    scheduledFor: scheduledFor,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'audience': audience,
    'titleKey': titleKey,
    'bodyKey': bodyKey,
    'parameters': parameters,
    'createdAt': createdAt.toIso8601String(),
    'appointmentId': appointmentId,
    'isRead': isRead,
    'scheduledFor': scheduledFor?.toIso8601String(),
  };

  factory ClinicNotification.fromJson(Map<String, dynamic> json) {
    final typeName = json['type']?.toString();
    final type = ClinicNotificationType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => ClinicNotificationType.appointmentReminder,
    );
    final rawParameters = json['parameters'];
    return ClinicNotification(
      id: json['id']?.toString() ?? '',
      type: type,
      audience: json['audience']?.toString() ?? '',
      titleKey: json['titleKey']?.toString() ?? '',
      bodyKey: json['bodyKey']?.toString() ?? '',
      parameters: rawParameters is Map
          ? rawParameters.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const {},
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      appointmentId: _int(json['appointmentId']),
      isRead: json['isRead'] == true,
      scheduledFor: DateTime.tryParse(
        json['scheduledFor']?.toString() ?? '',
      ),
    );
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class ClinicAppointmentNotificationSnapshot {
  const ClinicAppointmentNotificationSnapshot({
    required this.id,
    required this.personName,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
  });

  final int id;
  final String personName;
  final DateTime appointmentDate;
  final String status;
  final DateTime? lastStatusDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'personName': personName,
    'appointmentDate': appointmentDate.toIso8601String(),
    'status': status,
    'lastStatusDate': lastStatusDate?.toIso8601String(),
  };

  factory ClinicAppointmentNotificationSnapshot.fromJson(
    Map<String, dynamic> json,
  ) => ClinicAppointmentNotificationSnapshot(
    id: ClinicNotification._int(json['id']) ?? 0,
    personName: json['personName']?.toString() ?? '',
    appointmentDate:
        DateTime.tryParse(json['appointmentDate']?.toString() ?? '') ??
        DateTime.now(),
    status: json['status']?.toString() ?? '',
    lastStatusDate: DateTime.tryParse(
      json['lastStatusDate']?.toString() ?? '',
    ),
  );
}
