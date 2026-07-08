class CountryModel {
  final int Id;
  final String CountryName;

  CountryModel({required this.Id, required this.CountryName});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(Id: json['id'], CountryName: json['countryName']);
  }
}
