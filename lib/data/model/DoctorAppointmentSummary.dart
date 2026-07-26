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
    if (response == null) {
      return const DoctorAppointmentSummary(
        pending: 0,
        completed: 0,
        cancelled: 0,
      );
    }
    final payload = _unwrap(response);
    if (payload is List) return _fromStatusCounts(payload);
    if (payload is! Map) {
      throw const FormatException('Summary response must be a JSON object.');
    }
    final summaryMap = Map<String, dynamic>.from(payload);

    return DoctorAppointmentSummary(
      pending: parseInt(
        _requiredValue(summaryMap, const [
          'pending',
          'pendingCount',
          'pendingAppointments',
        ]),
      ),
      completed: parseInt(
        _requiredValue(summaryMap, const [
          'completed',
          'completedCount',
          'completedAppointments',
        ]),
      ),
      cancelled: parseInt(
        _requiredValue(summaryMap, const [
          'cancelled',
          'canceled',
          'cancelledCount',
          'canceledCount',
          'cancelledAppointments',
          'canceledAppointments',
        ]),
      ),
    );
  }

  factory DoctorAppointmentSummary.fromJson(Map<String, dynamic> json) =>
      DoctorAppointmentSummary.fromResponse(json);

  static int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Object? _unwrap(Object? response) {
    var current = response;
    for (var depth = 0; depth < 4 && current is Map; depth++) {
      final map = Map<dynamic, dynamic>.from(current);
      final nested = _value(map, const ['data', 'result', 'summary']);
      if (nested == null) {
        final values = _value(map, const [r'$values']);
        return values ?? map;
      }
      current = nested;
    }
    return current;
  }

  static DoctorAppointmentSummary _fromStatusCounts(List<dynamic> values) {
    final counts = <String, int>{};
    for (final item in values) {
      if (item is! Map) throw const FormatException();
      final status = _value(item, const ['status', 'name'])?.toString();
      final count = _value(item, const ['count', 'value']);
      if (status == null || count == null) throw const FormatException();
      counts[status.toLowerCase()] = parseInt(count);
    }
    return DoctorAppointmentSummary(
      pending: counts['pending'] ?? 0,
      completed: counts['completed'] ?? 0,
      cancelled: counts['cancelled'] ?? counts['canceled'] ?? 0,
    );
  }

  static Object? _requiredValue(Map<dynamic, dynamic> map, List<String> names) {
    final key = map.keys.cast<Object?>().whereType<String>().firstWhere(
      (candidate) =>
          names.any((name) => candidate.toLowerCase() == name.toLowerCase()),
      orElse: () => '',
    );
    if (key.isEmpty) {
      throw const FormatException('Summary response fields are missing.');
    }
    return map[key];
  }

  static Object? _value(Map<dynamic, dynamic> map, List<String> names) {
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
