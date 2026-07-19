class RegisterResponseModel {
  final int? id;
  final int? personId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? userName;
  final bool? isActive;
  final String? phoneNumber;
  final int? age;
  final String? nationalityNo;
  final String? roleName;
  final String? address;
  final int? gender;
  final int? nationalityCountryID;
  final String? imagePath;
  final String? note;

  const RegisterResponseModel({
    this.id,
    this.personId,
    this.firstName,
    this.lastName,
    this.email,
    this.userName,
    this.isActive,
    this.phoneNumber,
    this.age,
    this.nationalityNo,
    this.roleName,
    this.address,
    this.gender,
    this.nationalityCountryID,
    this.imagePath,
    this.note,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      id: _asInt(json['id']),
      personId: _asInt(json['personId']),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      userName: json['userName']?.toString(),
      isActive: json['isActive'] as bool?,
      phoneNumber: json['phoneNumber']?.toString(),
      age: _asInt(json['age']),
      nationalityNo: json['nationalityNo']?.toString(),
      roleName: json['roleName']?.toString(),
      address: json['address']?.toString(),
      gender: _asInt(json['gender']),
      nationalityCountryID: _asInt(json['nationalityCountryID']),
      imagePath: json['imagePath']?.toString(),
      note: json['note']?.toString(),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
