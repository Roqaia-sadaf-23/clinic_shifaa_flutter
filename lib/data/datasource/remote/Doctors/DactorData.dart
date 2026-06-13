import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '/core/constant/Applinkapi.dart';

class DoctorData {
  ApiService _crud = ApiService();
  DoctorData(this._crud);

  getdata() async {
    var response = await _crud.get(ApiLinks.doctors);
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }

  /* g etsearch(String search) async {
    var response = await _crud.get("${Applinkapi.search}/$search");
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  } */
}

// data/datasource/remote/Doctors/DoctorData.dart
