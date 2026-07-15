import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/TokenModel.dart';

class LoginData {
  final ApiService _apiService;

  LoginData(this._apiService);

  Future<Either<Failure, TokenModel>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.post(ApiLinks.login, {
      'login': email,
      'password': password,
    });

    return result.fold(
      (failure) => Left(failure),
      (json) => Right(TokenModel.fromJson(json as Map<String, dynamic>)),
    );
  }
}
