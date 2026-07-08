import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';

class CountryData {
  ApiService _crud = ApiService();
  CountryData();

  getCountries() async {
    var response = await _crud.get(ApiLinks.countries);
    print("===================  data Country $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}
