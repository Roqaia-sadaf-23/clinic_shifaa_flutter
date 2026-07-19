class CurrentDoctorModel {
  const CurrentDoctorModel({required this.id, required this.personId, required this.firstName, required this.lastName, required this.age, this.note, required this.experienceYears, required this.specialization, this.imagePath, required this.userId});

  final int id;
  final int personId;
  final String firstName;
  final String lastName;
  final int age;
  final String? note;
  final int experienceYears;
  final String specialization;
  final String? imagePath;
  final int userId;

  String get fullName => '$firstName $lastName'.trim();
  bool get hasImage => imagePath?.trim().isNotEmpty == true;

  factory CurrentDoctorModel.fromJson(Map<String, dynamic> json) => CurrentDoctorModel(
        id: _requiredInt(json, 'id'), personId: _requiredInt(json, 'personId'),
        firstName: _requiredString(json, 'firstName'), lastName: _requiredString(json, 'lastName'),
        age: _requiredInt(json, 'age'), note: _nullableString(json['note']),
        experienceYears: _requiredInt(json, 'experienceYears'),
        specialization: _requiredString(json, 'specialization'),
        imagePath: _nullableString(json['imagePath']), userId: _requiredInt(json, 'userId'));

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.roundToDouble()) return value.toInt();
    final parsed = value is String ? int.tryParse(value.trim()) : null;
    if (parsed != null) return parsed;
    throw FormatException('Invalid or missing $key.');
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    throw FormatException('Invalid or missing $key.');
  }

  static String? _nullableString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
