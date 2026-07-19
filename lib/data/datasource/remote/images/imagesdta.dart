import 'package:get/get.dart';

import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';

class ImagesData {
  ImagesData([ApiService? apiService])
    : _apiService = apiService ?? Get.find<ApiService>();

  final ApiService _apiService;

  // ignore: strict_top_level_inference
  uploadImage(String imagePath) async {
    final response = await _apiService.uploadImage(
      ApiLinks.uploadImage,
      imagePath,
    );

    return response.fold((L) => L, (R) => R);
  }

  Future<Either<Failure, String>> uploadAuthenticatedImageName(
    String imagePath,
  ) async {
    final response = await _apiService.uploadImage(
      ApiLinks.uploadImage,
      imagePath,
      auth: true,
    );
    return response.fold(Left.new, (json) {
      if (json is! Map) {
        return const Left(
          ServerFailure('Invalid image upload response from the server.'),
        );
      }
      final imageName = json['imageName'];
      if (imageName is! String || imageName.trim().isEmpty) {
        return const Left(
          ServerFailure('The server did not return an uploaded image name.'),
        );
      }
      return Right(imageName.trim());
    });
  }
}
