import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/registermodel.dart';

class SignupData {
  final ApiService _crud = ApiService();

  Future<dynamic> postDataUser(RegisterModel model) async {
    var response = await _crud.post(ApiLinks.adduser, model.toJson());

    print("=================== data $response");

    return response;
  }
}
