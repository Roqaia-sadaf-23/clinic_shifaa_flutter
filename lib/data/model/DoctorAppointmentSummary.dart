class DoctorAppointmentSummary {
  const DoctorAppointmentSummary({
    required this.pending,
    required this.completed,
    required this.cancelled,
  });

  final int pending;
  final int completed;
  final int cancelled;

  factory DoctorAppointmentSummary.fromResponse(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Summary response must be a JSON object.');
    }

    final responseMap = Map<String, dynamic>.from(response);
    final dynamic nested = responseMap['data'] ?? responseMap['result'];
    final summaryMap = nested == null
        ? responseMap
        : nested is Map
        ? Map<String, dynamic>.from(nested)
        : throw const FormatException(
            'Summary response wrapper must contain a JSON object.',
          );

    const requiredFields = {'pending', 'completed', 'cancelled'};
    if (!requiredFields.every(summaryMap.containsKey)) {
      throw const FormatException('Summary response fields are missing.');
    }

    return DoctorAppointmentSummary(
      pending: parseInt(summaryMap['pending']),
      completed: parseInt(summaryMap['completed']),
      cancelled: parseInt(summaryMap['cancelled']),
    );
  }

  factory DoctorAppointmentSummary.fromJson(Map<String, dynamic> json) =>
      DoctorAppointmentSummary.fromResponse(json);

  static int parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
