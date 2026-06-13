class register {
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _userName;
  String? _password;
  bool? _isActive;
  String? _nationalityNo;
  int? _roleId;
  int? _phoneNumber;
  int? _age;
  String? _address;
  String? _gender;
  int? _nationalityCountryId;
  String? _imagePath;
  String? _note;

  register({
    String? firstName,
    String? lastName,
    String? email,
    String? userName,
    String? password,
    bool? isActive,
    String? nationalityNo,
    int? roleId,
    int? phoneNumber,
    int? age,
    String? address,
    String? gender,
    int? nationalityCountryId,
    String? imagePath,
    String? note,
  }) {
    if (firstName != null) {
      this._firstName = firstName;
    }
    if (lastName != null) {
      this._lastName = lastName;
    }
    if (email != null) {
      this._email = email;
    }
    if (userName != null) {
      this._userName = userName;
    }
    if (password != null) {
      this._password = password;
    }
    if (isActive != null) {
      this._isActive = isActive;
    }
    if (nationalityNo != null) {
      this._nationalityNo = nationalityNo;
    }
    if (roleId != null) {
      this._roleId = roleId;
    }
    if (phoneNumber != null) {
      this._phoneNumber = phoneNumber;
    }
    if (age != null) {
      this._age = age;
    }
    if (address != null) {
      this._address = address;
    }
    if (gender != null) {
      this._gender = gender;
    }
    if (nationalityCountryId != null) {
      this._nationalityCountryId = nationalityCountryId;
    }
    if (imagePath != null) {
      this._imagePath = imagePath;
    }
    if (note != null) {
      this._note = note;
    }
  }

  String? get firstName => _firstName;
  set firstName(String? firstName) => _firstName = firstName;
  String? get lastName => _lastName;
  set lastName(String? lastName) => _lastName = lastName;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get userName => _userName;
  set userName(String? userName) => _userName = userName;
  String? get password => _password;
  set password(String? password) => _password = password;
  bool? get isActive => _isActive;
  set isActive(bool? isActive) => _isActive = isActive;
  String? get nationalityNo => _nationalityNo;
  set nationalityNo(String? nationalityNo) => _nationalityNo = nationalityNo;
  int? get roleId => _roleId;
  set roleId(int? roleId) => _roleId = roleId;
  int? get phoneNumber => _phoneNumber;
  set phoneNumber(int? phoneNumber) => _phoneNumber = phoneNumber;
  int? get age => _age;
  set age(int? age) => _age = age;
  String? get address => _address;
  set address(String? address) => _address = address;
  String? get gender => _gender;
  set gender(String? gender) => _gender = gender;
  int? get nationalityCountryId => _nationalityCountryId;
  set nationalityCountryId(int? nationalityCountryId) =>
      _nationalityCountryId = nationalityCountryId;
  String? get imagePath => _imagePath;
  set imagePath(String? imagePath) => _imagePath = imagePath;
  String? get note => _note;
  set note(String? note) => _note = note;

  register.fromJson(Map<String, dynamic> json) {
    _firstName = json['firstName'];
    _lastName = json['lastName'];
    _email = json['email'];
    _userName = json['userName'];
    _password = json['password'];
    _isActive = json['isActive'];
    _nationalityNo = json['nationalityNo'];
    _roleId = json['roleId'];
    _phoneNumber = json['phoneNumber'];
    _age = json['age'];
    _address = json['address'];
    _gender = json['gender'];
    _nationalityCountryId = json['nationalityCountryId'];
    _imagePath = json['imagePath'];
    _note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this._firstName;
    data['lastName'] = this._lastName;
    data['email'] = this._email;
    data['userName'] = this._userName;
    data['password'] = this._password;
    data['isActive'] = this._isActive;
    data['nationalityNo'] = this._nationalityNo;
    data['roleId'] = this._roleId;
    data['phoneNumber'] = this._phoneNumber;
    data['age'] = this._age;
    data['address'] = this._address;
    data['gender'] = this._gender;
    data['nationalityCountryId'] = this._nationalityCountryId;
    data['imagePath'] = this._imagePath;
    data['note'] = this._note;
    return data;
  }
}
