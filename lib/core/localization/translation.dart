import 'package:get/get.dart';

class MyTranslation extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en': {"1": "Choose  language", "2": "welcome back"},
    'ar': {"1": "اختر اللغة", "2": "مرحبا بعودتك"},
  };
}
