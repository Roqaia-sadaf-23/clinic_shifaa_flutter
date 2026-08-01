import 'DoctorAppointmentModel.dart';
import '../../core/helpers/image_path_helper.dart';

class AppointmentModel implements AppointmentDisplayData {
  @override
  final int id;
  final String doctorName;
  final int? doctorId;
  final int? patientId;
  final String? doctorSpecialization;
  final String? doctorImage;
  @override
  final String patientName;
  @override
  final DateTime appointmentDate;
  @override
  final String status;
  final DateTime? lastStatusDate;
  final int? medicalRecordId;
  final String? appointmentNotes;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    this.doctorId,
    this.patientId,
    this.doctorSpecialization,
    this.doctorImage,
    required this.patientName,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
    this.medicalRecordId,
    this.appointmentNotes,
  });

  @override
  String? get patientImage => null;

  @override
  String? get notes => appointmentNotes;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: _int(_value(json, 'id'), 'id'),
      doctorName: _string(_value(json, 'doctorName'), 'doctorName'),
      doctorId: _nullableInt(_value(json, 'doctorId')),
      patientId: _nullableInt(_value(json, 'patientId')),
      doctorSpecialization: _nullableString(
        _firstValue(json, const [
          'doctorSpecialization',
          'specialization',
          'specialty',
        ]),
      ),
      doctorImage: normalizeImagePath(
        _nullableString(_firstValue(json, const ['doctorImage', 'imagePath'])),
      ),
      patientName: _nullableString(_value(json, 'patientName')) ?? '',
      appointmentDate: _date(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      )!,
      status: _string(_value(json, 'status'), 'status'),
      lastStatusDate: _date(_value(json, 'lastStatusDate'), 'lastStatusDate'),
      medicalRecordId: _nullableInt(_value(json, 'medicalRecordId')),
      appointmentNotes: _nullableString(
        _firstValue(json, const ['notes', 'note']),
      ),
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
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorSpecialization': doctorSpecialization,
      'doctorImage': doctorImage,
      'patientName': patientName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'lastStatusDate': lastStatusDate?.toIso8601String(),
      'medicalRecordId': medicalRecordId,
      'notes': appointmentNotes,
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
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
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
