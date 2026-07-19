import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/CurrentDoctorModel.dart';

class DoctorData {
  DoctorData(this._apiService);
  final ApiService _apiService;

  Future<Either<Failure, CurrentDoctorModel>> getCurrentDoctor() async {
    final response = await _apiService.get(ApiLinks.currentDoctor, auth: true);
    return response.fold((failure) => Left(failure), (json) {
      if (json is! Map) {
        return const Left(ServerFailure('Invalid Doctor profile response from the server.'));
      }
      try {
        return Right(CurrentDoctorModel.fromJson(Map<String, dynamic>.from(json)));
      } catch (_) {
        return const Left(ServerFailure('Invalid Doctor profile response from the server.'));
      }
    });
  }
}
