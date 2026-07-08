import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class imagesdta {
  //crud _crud = crud();
  // ignore: prefer_final_fields
  ApiService _crud = ApiService();
  //imagesdta(this._crud);

  // ignore: strict_top_level_inference
  uploadImage(String imagePath) async {
    var response = await _crud.uploadImage(ApiLinks.uploadImage, imagePath);

    return response.fold((L) => L, (R) => R);
  }
}
