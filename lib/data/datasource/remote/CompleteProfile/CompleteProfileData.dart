import '../../../model/SpecialtyModel.dart';
import '../../../../core/constant/ApiLinks.dart';

class CompleteProfileData {
  static const specialtiesEndpoint = ApiLinks.specialties;

  /// This method deliberately returns no data yet. When the backend contract is
  /// ready, replace its body with GET /Specialties; the controller and UI can
  /// continue consuming [SpecialtyModel] unchanged.
  Future<List<SpecialtyModel>> getSpecialties() async {
    return const [];
  }
}
