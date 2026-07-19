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
        return const Left(
          ServerFailure('Invalid Doctor profile response from the server.'),
        );
      }
      try {
        return Right(
          CurrentDoctorModel.fromJson(Map<String, dynamic>.from(json)),
        );
      } catch (_) {
        return const Left(
          ServerFailure('Invalid Doctor profile response from the server.'),
        );
      }
    });
  }

  Future<Either<Failure, String>> updateCurrentPersonImage(
    String imagePath,
  ) async {
    final response = await _apiService.put(ApiLinks.updateCurrentPersonImage, {
      'imagePath': imagePath,
    }, auth: true);
    return response.fold(Left.new, (json) {
      if (json is! Map) {
        return const Left(
          ServerFailure('Invalid profile image response from the server.'),
        );
      }
      final savedPath = json['imagePath'];
      if (savedPath is! String || savedPath.trim().isEmpty) {
        return const Left(
          ServerFailure('The server did not confirm the profile image.'),
        );
      }
      return Right(savedPath.trim());
    });
  }

  Future<Either<Failure, CurrentDoctorModel>> updateCurrentDoctorProfile({
    required String firstName,
    required String lastName,
    required int age,
    required String note,
    required int experienceYears,
    required String specialization,
  }) async {
    final response = await _apiService.put(ApiLinks.currentDoctor, {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'note': note,
      'experienceYears': experienceYears,
      'specialization': specialization,
    }, auth: true);

    Failure? requestFailure;
    Object? responseBody;
    response.fold(
      (value) => requestFailure = value,
      (value) => responseBody = value,
    );
    if (requestFailure != null) return Left(requestFailure!);

    if (responseBody is Map) {
      try {
        return Right(
          CurrentDoctorModel.fromJson(
            Map<String, dynamic>.from(responseBody! as Map),
          ),
        );
      } on FormatException {
        // Some backend versions return a reduced update response. Fetch the
        // canonical authenticated profile rather than inventing identifiers.
      }
    }
    return getCurrentDoctor();
  }
}
