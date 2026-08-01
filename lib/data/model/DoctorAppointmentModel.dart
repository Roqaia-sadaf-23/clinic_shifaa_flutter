import '../../core/helpers/image_path_helper.dart';

abstract interface class AppointmentDisplayData {
  int get id;
  String get patientName;
  String? get patientImage;
  DateTime get appointmentDate;
  String get status;
  String? get notes;
}

class DoctorAppointmentModel implements AppointmentDisplayData {
  const DoctorAppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
    this.medicalRecordId,
    this.notes,
  });

  @override
  final int id;
  final int patientId;
  @override
  final String patientName;
  @override
  final String? patientImage;
  @override
  final DateTime appointmentDate;
  @override
  final String status;
  final DateTime? lastStatusDate;
  final int? medicalRecordId;
  @override
  final String? notes;

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      id: _requiredInt(_value(json, 'id'), 'id'),
      patientId: _requiredInt(_value(json, 'patientId'), 'patientId'),
      patientName: _string(_value(json, 'patientName')) ?? '',
      patientImage: normalizeImagePath(_string(_value(json, 'patientImage'))),
      appointmentDate: _requiredDate(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      ),
      status: _string(_value(json, 'status')) ?? '',
      lastStatusDate: _date(_value(json, 'lastStatusDate')),
      medicalRecordId: _int(_value(json, 'medicalRecordId')),
      notes: _string(_value(json, 'notes')),
    );
  }

  static Object? _value(Map<String, dynamic> json, String name) {
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }

  static int _requiredInt(Object? value, String field) =>
      _int(value) ?? (throw FormatException('Invalid $field.'));

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _string(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime _requiredDate(Object? value, String field) =>
      _date(value) ?? (throw FormatException('Invalid $field.'));

  static DateTime? _date(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class DoctorAppointmentsResponse {
  const DoctorAppointmentsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final List<DoctorAppointmentModel> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  factory DoctorAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = _value(json, 'items');
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map(
                (item) => DoctorAppointmentModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
        : const <DoctorAppointmentModel>[];

    return DoctorAppointmentsResponse(
      items: items,
      page: _int(_value(json, 'page')) ?? 1,
      pageSize: _int(_value(json, 'pageSize')) ?? 10,
      totalCount: _int(_value(json, 'totalCount')) ?? items.length,
      totalPages: _int(_value(json, 'totalPages')) ?? 0,
    );
  }

  factory DoctorAppointmentsResponse.fromList(
    List<dynamic> values, {
    required int page,
    required int pageSize,
  }) {
    final items = values
        .whereType<Map>()
        .map(
          (item) =>
              DoctorAppointmentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    return DoctorAppointmentsResponse(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: items.length,
      totalPages: items.isEmpty ? 0 : 1,
    );
  }

  factory DoctorAppointmentsResponse.empty({
    required int page,
    required int pageSize,
  }) {
    return DoctorAppointmentsResponse(
      items: const [],
      page: page,
      pageSize: pageSize,
      totalCount: 0,
      totalPages: 0,
    );
  }

  static Object? _value(Map<String, dynamic> json, String name) {
    for (final entry in json.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
