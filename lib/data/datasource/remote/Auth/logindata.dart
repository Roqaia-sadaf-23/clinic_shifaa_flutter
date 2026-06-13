import '../../../../core/class/ApiService.dart';
import '/core/constant/Applinkapi.dart';

class login_data {
  //crud _crud = crud();
  ApiService _crud = ApiService();
  login_data(this._crud);

  postIsuserexit(String email, String password) async {
    var response = await _crud.post(Applinkapi.login, {
      "email": email,
      "password": password,
    });
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}
