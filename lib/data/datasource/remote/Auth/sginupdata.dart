import '../../../../core/class/ApiService.dart';
import '/core/constant/Applinkapi.dart';

class sginup_data {
  //crud _crud = crud();
  ApiService _crud = ApiService();

  sginup_data(this._crud);

  postDatauser(
    String username,
    String email,
    String phone,
    String password,
  ) async {
    var response = await _crud.post(Applinkapi.adduser, {
      "name": username,
      "email": email,
      "phone": phone,
      "password": password,
    });
    print("===================  data $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}
