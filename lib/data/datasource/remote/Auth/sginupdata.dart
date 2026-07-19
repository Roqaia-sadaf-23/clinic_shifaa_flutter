import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/RegisterResponseModel.dart';
import '../../../model/registermodel.dart';

class SignupData {
  final ApiService _apiService;

  SignupData(this._apiService);

  Future<Either<Failure, RegisterResponseModel>> postDataUser(
    RegisterModel model,
  ) async {
    final result = await _apiService.post(ApiLinks.adduser, model.toJson());

    return result.fold(
      (failure) => Left(failure),
      (json) {
        try {
          if (json is! Map) {
            return const Left(
              ServerFailure('Invalid registration response received from the server.'),
            );
          }
          final response = RegisterResponseModel.fromJson(
            Map<String, dynamic>.from(json),
          );
          if (response.personId == null || response.personId! <= 0) {
            return const Left(
              ServerFailure(
                'Registration succeeded but no valid personId was returned.',
              ),
            );
          }
          return Right(response);
        } catch (_) {
          return const Left(
            ServerFailure(
              'Unable to parse the registration response from the server.',
            ),
          );
        }
      },
    );
  }
}
