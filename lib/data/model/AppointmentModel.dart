class AppointmentModel {
  final int id;
  final int doctorId;
  final int patientId;
  final DateTime appointmentDate;
  final String status;
  final DateTime? lastStatusDate;
  final int? medicalRecordId;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
    this.medicalRecordId,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: _int(json['id'], 'id'),
      doctorId: _int(json['doctorId'], 'doctorId'),
      patientId: _int(json['patientId'], 'patientId'),
      appointmentDate: _date(json['appointmentDate'], 'appointmentDate')!,
      status: _string(json['status'], 'status'),
      lastStatusDate: _date(json['lastStatusDate'], 'lastStatusDate'),
      medicalRecordId: _nullableInt(json['medicalRecordId']),
      notes: _nullableString(json['notes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'lastStatusDate': lastStatusDate?.toIso8601String(),
      'medicalRecordId': medicalRecordId,
      'notes': notes,
    };
  }

  static int _int(Object? value, String field) =>
      _nullableInt(value) ?? (throw FormatException('Invalid $field.'));

  static int? _nullableInt(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return value is String ? int.tryParse(value) : null;
  }

  static DateTime? _date(Object? value, String field) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) throw FormatException('Invalid $field.');
    return parsed;
  }

  static String _string(Object? value, String field) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw FormatException('Invalid $field.');
  }

  static String? _nullableString(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }
}
