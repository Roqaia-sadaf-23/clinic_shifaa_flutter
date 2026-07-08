import 'package:clinic_shifaa/data/model/DoctorModel.dart';

import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class DoctorData {
  ApiService _crud;
  DoctorData(this._crud);

  getdata() async {
    var response = await _crud.get(ApiLinks.doctorById(6));

    return response.fold(
      (failure) {
        print("ERROR = $failure");
        return null;
      },
      (data) {
        print("DATA = $data");
        return DoctorDetailsModel.fromJson(data);
      },
    );
  }
}
  /* g etsearch(String search) async {
    var response = await _crud.get("${Applinkapi.search}/$search");
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  } */


// data/datasource/remote/Doctors/DoctorData.dart
