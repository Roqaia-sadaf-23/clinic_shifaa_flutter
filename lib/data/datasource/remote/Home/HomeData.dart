import '../../../../core/class/ApiService.dart';
import '/core/constant/Applinkapi.dart';

class HomeData {
  ApiService _crud = ApiService();
  HomeData(this._crud);

  getdata() async {
    var response = await _crud.get(Applinkapi.CategorlesData);
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }

  GetAllcateforyItemswithdescount() async {
    var response = await _crud.get(
      Applinkapi.GetAllcateforyItemswithdescount,
    );
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }

  getsearch(String search) async {
    var response = await _crud.get("${Applinkapi.search}/$search");
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}


// data/datasource/remote/Home/HomeData.dart

