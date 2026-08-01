class AvailableSlotModel {
  const AvailableSlotModel({required this.startTime, required this.endTime});

  final DateTime startTime;
  final DateTime endTime;

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    final startTime = _dateValue(json, 'startTime');
    final endTime = _dateValue(json, 'endTime');
    if (startTime == null || endTime == null) {
      throw const FormatException('Invalid available appointment slot.');
    }
    return AvailableSlotModel(startTime: startTime, endTime: endTime);
  }

  static List<AvailableSlotModel> listFromResponse(Object? response) {
    var current = response;
    for (var depth = 0; depth < 5; depth++) {
      if (current is List) {
        return current
            .whereType<Map>()
            .map(
              (item) =>
                  AvailableSlotModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      }
      if (current is! Map) break;
      final map = Map<String, dynamic>.from(current);
      current = _value(map, const [
        'data',
        'result',
        'items',
        'value',
        r'$values',
      ]);
    }
    if (response == null) return const [];
    throw const FormatException(
      'Available slots response must contain a list.',
    );
  }

  static DateTime? _dateValue(Map<dynamic, dynamic> map, String name) {
    final value = _value(map, [name]);
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString().trim() ?? '');
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
