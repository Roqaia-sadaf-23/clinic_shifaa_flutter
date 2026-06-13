import 'package:get/get_utils/src/get_utils/get_utils.dart';

// ignore: non_constant_identifier_names

String? ValdatioInput(String val, int min, int max, String type) {
  if (val.isEmpty) {
    return 'This field can’t be empty';
  }

  if (val.length < min || val.length > max) {
    return 'Value must be between $min and $max characters';
  }

  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "Not a valid username";
    }
  }

  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "Not a valid email";
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "Not a valid phone number";
    }
  }

  // For password, we already checked length and emptiness
  // You can add more rules here if needed

  return null; // ✅ Very important: return null if input is valid
}
