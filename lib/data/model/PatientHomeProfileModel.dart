// ignore_for_file: file_names

import '../../core/helpers/image_path_helper.dart';

class PatientHomeProfileModel {
  const PatientHomeProfileModel({
    required this.userId,
    required this.patientId,
    required this.personId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.imagePath,
    this.bloodType,
    this.age,
    this.gender,
  });

  final int userId;
  final int patientId;
  final int personId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? imagePath;
  final String? bloodType;
  final int? age;
  final Object? gender;

  String get fullName => '$firstName $lastName'.trim();
  bool get hasImage => isValidImagePath(imagePath);

  factory PatientHomeProfileModel.fromJson(
    Map<String, dynamic> json, {
    int fallbackUserId = 0,
  }) {
    final fullName = _text(_value(json, 'patientName'));
    final parts = fullName?.split(RegExp(r'\s+')) ?? const <String>[];
    return PatientHomeProfileModel(
      userId: _int(_firstValue(json, const ['userId', 'id'])) ?? fallbackUserId,
      patientId: _int(_firstValue(json, const ['patientId', 'patientID'])) ?? 0,
      personId: _int(_value(json, 'personId')) ?? 0,
      firstName:
          _text(_value(json, 'firstName')) ??
          (parts.isEmpty ? '' : parts.first),
      lastName:
          _text(_value(json, 'lastName')) ??
          (parts.length < 2 ? '' : parts.skip(1).join(' ')),
      email: _text(_value(json, 'email')),
      imagePath: normalizeImagePath(
        _text(_firstValue(json, const ['imagePath', 'patientImage'])),
      ),
      bloodType: _text(_value(json, 'bloodType')),
      age: _int(_value(json, 'age')),
      gender: _value(json, 'gender'),
    );
  }

  PatientHomeProfileModel merge(PatientHomeProfileModel other) {
    return PatientHomeProfileModel(
      userId: userId > 0 ? userId : other.userId,
      patientId: patientId > 0 ? patientId : other.patientId,
      personId: personId > 0 ? personId : other.personId,
      firstName: firstName.isNotEmpty ? firstName : other.firstName,
      lastName: lastName.isNotEmpty ? lastName : other.lastName,
      email: email ?? other.email,
      imagePath: imagePath ?? other.imagePath,
      bloodType: bloodType ?? other.bloodType,
      age: age ?? other.age,
      gender: gender ?? other.gender,
    );
  }

  static Object? _value(Map<String, dynamic> json, String name) {
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }

  static Object? _firstValue(Map<String, dynamic> json, List<String> names) {
    for (final name in names) {
      final value = _value(json, name);
      if (value != null) return value;
    }
    return null;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
