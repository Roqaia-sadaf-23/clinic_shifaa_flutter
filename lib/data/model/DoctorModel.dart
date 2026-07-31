class DoctorDetailsModel {
  final int id;
  final int personId;
  final String firstName;
  final String lastName;
  final int age;
  final int? experienceYears;
  final String? note;
  final String specialization;
  final String? imagePath;
  final int userId;

  DoctorDetailsModel({
    required this.id,
    required this.personId,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.experienceYears,
    this.note,
    required this.specialization,
    this.imagePath,
    required this.userId,
  });

  factory DoctorDetailsModel.fromJson(Map<String, dynamic> json) {
    return DoctorDetailsModel(
      id: _requiredInt(_value(json, 'id'), 'id'),
      personId: _int(_value(json, 'personId')) ?? 0,
      firstName: _text(_value(json, 'firstName')) ?? '',
      lastName: _text(_value(json, 'lastName')) ?? '',
      age: _int(_value(json, 'age')) ?? 0,
      experienceYears: _int(_value(json, 'experienceYears')),
      note: _text(_value(json, 'note')),
      specialization:
          _text(_firstValue(json, const ['specialization', 'specialty'])) ?? '',
      imagePath: _text(_value(json, 'imagePath')),
      userId: _int(_value(json, 'userId')) ?? 0,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  bool get hasImage => imagePath?.trim().isNotEmpty == true;

  static List<DoctorDetailsModel> listFromResponse(Object? response) {
    final values = _responseList(response);
    return values
        .whereType<Map>()
        .map(
          (item) =>
              DoctorDetailsModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'experienceYears': experienceYears,
      'note': note,
      'specialization': specialization,
      'imagePath': imagePath,
      'userId': userId,
    };
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

  static List<dynamic> _responseList(Object? response) {
    var current = response;
    for (var depth = 0; depth < 5; depth++) {
      if (current is List) return current;
      if (current is! Map) break;
      current = _dynamicValue(current, const [
        'data',
        'result',
        'items',
        'doctors',
        'value',
        r'$values',
      ]);
    }
    if (response == null) return const [];
    throw const FormatException('Doctors response must contain a list.');
  }

  static Object? _dynamicValue(Map<dynamic, dynamic> map, List<String> names) {
    for (final entry in map.entries) {
      final key = entry.key;
      if (key is String &&
          names.any((name) => key.toLowerCase() == name.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  static int _requiredInt(Object? value, String field) =>
      _int(value) ?? (throw FormatException('Invalid $field.'));

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
