class RoleModel {
  final int Id;
  final String roleName;
  final String description;

  RoleModel({
    required this.Id,
    required this.roleName,
    required this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      Id: json['id'],
      roleName: json['roleName'],
      description: json['description'],
    );
  }
}
