import '../../../../../core/class/ApiService.dart';
import '/core/constant/Applinkapi.dart';

class resetpassword_data {
  ApiService _crud = ApiService();

  resetpassword_data(this._crud);

  postResetpassword(String email, String password) async {
    var response = await _crud.post(Applinkapi.ResetPassword, {
      "email": email,
      "password": password,
    });
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}
