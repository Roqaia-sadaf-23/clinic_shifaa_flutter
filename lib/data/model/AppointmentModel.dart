class AppointmentModel {
  final int id;
  final String doctorName;
  final String patientName;
  final DateTime appointmentDate;
  final String status;
  final DateTime? lastStatusDate;
  final int? medicalRecordId;
  

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
    this.medicalRecordId,
    });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: _int(_value(json, 'id'), 'id'),
      doctorName: _string(_value(json, 'doctorName'), 'doctorName'),
      patientName: _string(_value(json, 'patientName'), 'patientName'),
      appointmentDate: _date(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      )!,
      status: _string(_value(json, 'status'), 'status'),
      lastStatusDate: _date(_value(json, 'lastStatusDate'), 'lastStatusDate'),
      medicalRecordId: _nullableInt(_value(json, 'medicalRecordId')),
    );
  }

  static List<AppointmentModel> listFromResponse(Object? response) {
    final values = _responseList(response);
    return values
        .map(
          (item) =>
              AppointmentModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'patientName': patientName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'lastStatusDate': lastStatusDate?.toIso8601String(),
      'medicalRecordId': medicalRecordId,
   
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

  static Object? _value(Map<String, dynamic> json, String name) {
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }

  static List<dynamic> _responseList(Object? response) {
    if (response == null) return const [];
    var current = response;
    for (var depth = 0; depth < 5; depth++) {
      if (current is List) return current;
      if (current is! Map) break;
      final nested = _firstValue(current, const [
        'data',
        'result',
        'items',
        'appointments',
        r'$values',
      ]);
      if (nested == null) break;
      current = nested;
    }
    throw const FormatException('Appointments response must contain a list.');
  }

  static Object? _firstValue(Map<dynamic, dynamic> map, List<String> names) {
    for (final entry in map.entries) {
      final key = entry.key;
      if (key is String &&
          names.any((name) => key.toLowerCase() == name.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
