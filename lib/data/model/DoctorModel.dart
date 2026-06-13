class DoctorDetailsModel {
  final int id;
  final int personId;
  final String firstName;
  final String lastName;
  final int age;
  final String? note;
  final String specialization;
  final String imagePath;
  final int userId;

  DoctorDetailsModel({
    required this.id,
    required this.personId,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.note,
    required this.specialization,
    required this.imagePath,
    required this.userId,
  });

  factory DoctorDetailsModel.fromJson(Map<String, dynamic> json) {
    return DoctorDetailsModel(
      id: json['id'],
      personId: json['personId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      note: json['note'],
      specialization: json['specialization'],
      imagePath: json['imagePath'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'note': note,
      'specialization': specialization,
      'imagePath': imagePath,
      'userId': userId,
    };
  }
}
