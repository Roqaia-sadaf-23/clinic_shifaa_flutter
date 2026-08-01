import 'DoctorAppointmentModel.dart';
import '../../core/helpers/image_path_helper.dart';

class CreateMedicalRecordRequest {
  const CreateMedicalRecordRequest({
    required this.appointmentId,
    required this.diagnosis,
    this.visitDescription,
    this.notes,
  });

  final int appointmentId;
  final String diagnosis;
  final String? visitDescription;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'appointmentId': appointmentId,
    'diagnosis': diagnosis,
    'visitDescription': visitDescription,
    'notes': notes,
  };
}

class CreatePrescriptionRequest {
  const CreatePrescriptionRequest({
    required this.medicalRecordId,
    required this.medicationName,
    this.frequency,
    this.dosage,
    this.specialInstructions,
  });

  final int medicalRecordId;
  final String medicationName;
  final String? frequency;
  final String? dosage;
  final String? specialInstructions;

  Map<String, dynamic> toJson() => {
    'medicalRecordId': medicalRecordId,
    'medicationName': medicationName,
    'frequency': frequency,
    'dosage': dosage,
    'specialInstructions': specialInstructions,
  };
}

class MedicalRecordFormArguments {
  const MedicalRecordFormArguments({
    required this.patientId,
    required this.appointmentId,
    required this.appointment,
  });

  final int patientId;
  final int appointmentId;
  final DoctorPatientAppointmentDetailsModel appointment;
}

class PrescriptionFormArguments {
  const PrescriptionFormArguments({
    required this.patientId,
    required this.medicalRecordId,
    required this.medicalRecord,
  });

  final int patientId;
  final int medicalRecordId;
  final DoctorPatientMedicalRecordModel medicalRecord;
}

class CreatedMedicalRecordResult {
  const CreatedMedicalRecordResult({this.medicalRecordId});

  final int? medicalRecordId;

  factory CreatedMedicalRecordResult.fromResponse(Object? response) {
    return CreatedMedicalRecordResult(
      medicalRecordId: _createdId(response, const ['medicalRecordId', 'id']),
    );
  }
}

class CreatedPrescriptionResult {
  const CreatedPrescriptionResult({this.prescriptionId});

  final int? prescriptionId;

  factory CreatedPrescriptionResult.fromResponse(Object? response) {
    return CreatedPrescriptionResult(
      prescriptionId: _createdId(response, const ['prescriptionId', 'id']),
    );
  }
}

class DoctorPatientAppointmentDetailsModel implements AppointmentDisplayData {
  const DoctorPatientAppointmentDetailsModel({
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    this.bloodType,
    this.age,
    this.phoneNumber,
    required this.appointmentDate,
    required this.status,
    this.lastStatusDate,
    this.note,
  });

  final int appointmentId;
  final int patientId;
  @override
  final String patientName;
  @override
  final String? patientImage;
  final String? bloodType;
  final int? age;
  final String? phoneNumber;
  @override
  final DateTime appointmentDate;
  @override
  final String status;
  final DateTime? lastStatusDate;
  final String? note;

  @override
  int get id => appointmentId;

  @override
  String? get notes => note;

  factory DoctorPatientAppointmentDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DoctorPatientAppointmentDetailsModel(
      appointmentId: _requiredInt(
        _firstValue(json, const ['appointmentId', 'id']),
        'appointmentId',
      ),
      patientId: _requiredInt(_value(json, 'patientId'), 'patientId'),
      patientName: _text(_value(json, 'patientName')) ?? '',
      patientImage: normalizeImagePath(_text(_value(json, 'patientImage'))),
      bloodType: _text(_value(json, 'bloodType')),
      age: _int(_value(json, 'age')),
      phoneNumber: _text(_value(json, 'phoneNumber')),
      appointmentDate: _requiredDate(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      ),
      status: _text(_value(json, 'status')) ?? '',
      lastStatusDate: _date(_value(json, 'lastStatusDate')),
      note: _text(_firstValue(json, const ['note', 'notes'])),
    );
  }
}

class DoctorPatientMedicalRecordModel {
  const DoctorPatientMedicalRecordModel({
    required this.medicalRecordId,
    required this.appointmentId,
    required this.appointmentDate,
    required this.diagnosis,
    this.visitDescription,
    this.notes,
  });

  final int medicalRecordId;
  final int appointmentId;
  final DateTime appointmentDate;
  final String diagnosis;
  final String? visitDescription;
  final String? notes;

  factory DoctorPatientMedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return DoctorPatientMedicalRecordModel(
      medicalRecordId: _requiredInt(
        _firstValue(json, const ['medicalRecordId', 'id']),
        'medicalRecordId',
      ),
      appointmentId: _requiredInt(
        _value(json, 'appointmentId'),
        'appointmentId',
      ),
      appointmentDate: _requiredDate(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      ),
      diagnosis: _text(_value(json, 'diagnosis')) ?? '',
      visitDescription: _text(_value(json, 'visitDescription')),
      notes: _text(_value(json, 'notes')),
    );
  }
}

class DoctorPatientPrescriptionModel {
  const DoctorPatientPrescriptionModel({
    required this.prescriptionId,
    required this.medicalRecordId,
    required this.appointmentId,
    required this.appointmentDate,
    required this.medicationName,
    this.dosage,
    this.frequency,
    this.specialInstructions,
  });

  final int prescriptionId;
  final int medicalRecordId;
  final int appointmentId;
  final DateTime appointmentDate;
  final String medicationName;
  final String? dosage;
  final String? frequency;
  final String? specialInstructions;

  factory DoctorPatientPrescriptionModel.fromJson(Map<String, dynamic> json) {
    return DoctorPatientPrescriptionModel(
      prescriptionId: _requiredInt(
        _firstValue(json, const ['prescriptionId', 'id']),
        'prescriptionId',
      ),
      medicalRecordId: _requiredInt(
        _value(json, 'medicalRecordId'),
        'medicalRecordId',
      ),
      appointmentId: _requiredInt(
        _value(json, 'appointmentId'),
        'appointmentId',
      ),
      appointmentDate: _requiredDate(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      ),
      medicationName: _text(_value(json, 'medicationName')) ?? '',
      dosage: _text(_value(json, 'dosage')),
      frequency: _text(_value(json, 'frequency')),
      specialInstructions: _text(_value(json, 'specialInstructions')),
    );
  }
}

class DoctorPatientPaymentModel {
  const DoctorPatientPaymentModel({
    required this.paymentId,
    required this.appointmentId,
    required this.appointmentDate,
    required this.amount,
    this.paymentMethod,
    this.status,
    required this.createdAt,
    this.note,
  });

  final int paymentId;
  final int appointmentId;
  final DateTime appointmentDate;
  final double amount;
  final String? paymentMethod;
  final String? status;
  final DateTime createdAt;
  final String? note;

  factory DoctorPatientPaymentModel.fromJson(Map<String, dynamic> json) {
    return DoctorPatientPaymentModel(
      paymentId: _requiredInt(
        _firstValue(json, const ['paymentId', 'id']),
        'paymentId',
      ),
      appointmentId: _requiredInt(
        _value(json, 'appointmentId'),
        'appointmentId',
      ),
      appointmentDate: _requiredDate(
        _value(json, 'appointmentDate'),
        'appointmentDate',
      ),
      amount: _requiredDouble(_value(json, 'amount'), 'amount'),
      paymentMethod: _text(_value(json, 'paymentMethod')),
      status: _text(_value(json, 'status')),
      createdAt: _requiredDate(_value(json, 'createdAt'), 'createdAt'),
      note: _text(_value(json, 'note')),
    );
  }
}

Object? _value(Map<String, dynamic> json, String name) {
  for (final entry in json.entries) {
    if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
  }
  return null;
}

Object? _firstValue(Map<String, dynamic> json, List<String> names) {
  for (final name in names) {
    final value = _value(json, name);
    if (value != null) return value;
  }
  return null;
}

int _requiredInt(Object? value, String field) =>
    _int(value) ?? (throw FormatException('Invalid $field.'));

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num && value.isFinite) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

double _requiredDouble(Object? value, String field) =>
    _double(value) ?? (throw FormatException('Invalid $field.'));

double? _double(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime _requiredDate(Object? value, String field) =>
    _date(value) ?? (throw FormatException('Invalid $field.'));

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

int? _createdId(Object? response, List<String> names) {
  final direct = _int(response);
  if (direct != null) return direct;
  if (response is! Map) return null;

  final value = _dynamicMapValue(response, names);
  final parsed = _int(value);
  if (parsed != null) return parsed;

  final nested = _dynamicMapValue(response, const ['data', 'result']);
  if (identical(nested, response)) return null;
  return _createdId(nested, names);
}

Object? _dynamicMapValue(Map<dynamic, dynamic> map, List<String> names) {
  for (final name in names) {
    for (final entry in map.entries) {
      final key = entry.key;
      if (key is String && key.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
  }
  return null;
}
