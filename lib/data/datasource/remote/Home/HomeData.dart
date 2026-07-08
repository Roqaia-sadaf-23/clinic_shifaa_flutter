import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class HomeData {
  ApiService _crud = ApiService();
  HomeData(this._crud);

  getdata() async {
    var response = await _crud.get(ApiLinks.appointments);
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }

  GetAllcateforyItemswithdescount() async {
    var response = await _crud.get(ApiLinks.prescriptions);
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }

  /* 
  getsearch(String search) async {
    var response = await _crud.get("${Applinkapi.search}/$search");
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  } */
}


// data/datasource/remote/Home/HomeData.dart

