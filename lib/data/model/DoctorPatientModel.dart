import '../../core/helpers/image_path_helper.dart';

class DoctorPatientModel {
  const DoctorPatientModel({
    required this.patientId,
    required this.patientName,
    this.patientImage,
    this.bloodType,
    required this.appointmentsCount,
    this.lastAppointmentDate,
  });

  final int patientId;
  final String patientName;
  final String? patientImage;
  final String? bloodType;
  final int appointmentsCount;
  final DateTime? lastAppointmentDate;

  factory DoctorPatientModel.fromJson(Map<String, dynamic> json) {
    return DoctorPatientModel(
      patientId: _requiredInt(json['patientId'], 'patientId'),
      patientName: _requiredText(json['patientName'], 'patientName'),
      patientImage: normalizeImagePath(_text(json['patientImage'])),
      bloodType: _text(json['bloodType']),
      appointmentsCount: _requiredInt(
        json['appointmentsCount'],
        'appointmentsCount',
      ),
      lastAppointmentDate: DateTime.tryParse(
        json['lastAppointmentDate']?.toString() ?? '',
      ),
    );
  }

  static int _requiredInt(Object? value, String field) {
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      return value.toInt();
    }
    final parsed = value is String ? int.tryParse(value.trim()) : null;
    if (parsed != null) return parsed;
    throw FormatException('Invalid $field.');
  }

  static String? _text(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  static String _requiredText(Object? value, String field) =>
      _text(value) ?? (throw FormatException('Invalid $field.'));
}
