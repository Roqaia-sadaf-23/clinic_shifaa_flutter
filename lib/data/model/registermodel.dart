class RegisterModel {
  String? firstName;
  String? lastName;
  String? email;
  String? userName;
  String? password;
  bool? isActive;
  String? nationalityNo;
  int? roleId;
  String? phoneNumber;
  int? age;
  String? address;
  int? gender;
  int? nationalityCountryId;
  String? imagePath;
  String? note;

  RegisterModel({
    this.firstName,
    this.lastName,
    this.email,
    this.userName,
    this.password,
    this.isActive,
    this.nationalityNo,
    this.roleId,
    this.phoneNumber,
    this.age,
    this.address,
    this.gender,
    this.nationalityCountryId,
    this.imagePath,
    this.note,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      userName: json['userName'],
      password: json['password'],
      isActive: json['isActive'],
      nationalityNo: json['nationalityNo'],
      roleId: json['roleId'],
      phoneNumber: json['phoneNumber']?.toString(),
      age: json['age'],
      address: json['address'],
      gender: json['gender'],
      nationalityCountryId: json['nationalityCountryId'],
      imagePath: json['imagePath'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "userName": userName,
      "password": password,
      "isActive": isActive,
      "nationalityNo": nationalityNo,
      "roleId": roleId,
      "phoneNumber": phoneNumber,
      "age": age,
      "address": address,
      "gender": gender,
      "nationalityCountryId": nationalityCountryId,
      "imagePath": imagePath ?? "",
      "note": note ?? "",
    };
  }
}
