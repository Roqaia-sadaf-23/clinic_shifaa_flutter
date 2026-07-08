import 'package:clinic_shifaa/core/class/ApiService.dart';
import 'package:clinic_shifaa/core/constant/ApiLinks.dart';

class RoleData {
  ApiService _crud = ApiService();
  RoleData();

  getRoles() async {
    var response = await _crud.get(ApiLinks.roles);
    print("===================  data Role $response");
    // التعامل مع الاستجابة
    return response.fold((L) => L, (R) => R);
  }
}
