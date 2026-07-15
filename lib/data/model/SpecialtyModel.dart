class SpecialtyModel {
  final int id;
  final String name;

  const SpecialtyModel({required this.id, required this.name});

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(id: json['id'] as int, name: json['name'] as String);
  }
}
