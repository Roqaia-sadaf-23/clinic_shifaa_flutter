class AppointmentModel {
  final int id;
  final int doctorId;
  final int patientId;
  final DateTime appointmentDate;
  final String status;
  final DateTime lastStatusDate;
  final int? medicalRecordId;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    required this.lastStatusDate,
    this.medicalRecordId,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      status: json['status'],
      lastStatusDate: DateTime.parse(json['lastStatusDate']),
      medicalRecordId: json['medicalRecordId'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'lastStatusDate': lastStatusDate.toIso8601String(),
      'medicalRecordId': medicalRecordId,
      'notes': notes,
    };
  }
}