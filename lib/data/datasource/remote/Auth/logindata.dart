import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/TokenModel.dart';

class LoginData {
  final ApiService _apiService;

  LoginData(this._apiService);

  Future<Either<Failure, TokenModel>> login({
    required String login,
    required String password,
  }) async {
    final result = await _apiService.post(ApiLinks.login, {
      'login': login,
      'password': password,
    });

    return result.fold(
      (failure) => Left(failure),
      (json) {
        try {
          if (json is! Map) {
            return const Left(
              ServerFailure('Invalid login response received from the server.'),
            );
          }
          return Right(TokenModel.fromJson(Map<String, dynamic>.from(json)));
        } catch (_) {
          return const Left(
            ServerFailure('Unable to parse the login response from the server.'),
          );
        }
      },
    );
  }
}
