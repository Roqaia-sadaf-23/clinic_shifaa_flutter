import '../../../../core/Error/Failure.dart';
import '../../../../core/class/ApiService.dart';
import '../../../../core/constant/ApiLinks.dart';
import '../../../model/SpecialtyModel.dart';

class CompleteProfileData {
  CompleteProfileData(this._apiService);

  final ApiService _apiService;

  Future<List<SpecialtyModel>> getSpecialties() async {
    return const [];
  }

  Future<Either<Failure, void>> createDoctor({
    required String specialty,
    required DateTime hireDate,
    required int personId,
    required int experienceYear,
  }) async {
    final result = await _apiService.post(ApiLinks.Adddoctors, {
      'specialty': specialty,
      'hiredate': hireDate.toUtc().toIso8601String(),
      'personId': personId,
      'experienceYear': experienceYear,
    }, auth: true);

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  Future<Either<Failure, void>> createPatient({
    required String bloodType,
    required int personId,
  }) async {
    final result = await _apiService.post(ApiLinks.patients, {
      'bloodType': bloodType,
      'personId': personId,
    }, auth: true);

    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }
}
