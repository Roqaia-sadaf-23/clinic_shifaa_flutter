import 'package:get/get.dart';
import 'Bindings/CompleteProfileBinding.dart';
import 'Bindings/SplashBinding.dart';
import 'Bindings/DoctorHomeBinding.dart';
import 'Bindings/PatientHomeBinding.dart';
import 'Bindings/DoctorEditProfileBinding.dart';
import 'Bindings/DoctorAppointmentDetailsBinding.dart';
import 'Bindings/DoctorPatientDetailsBinding.dart';
import 'View/Screen/Auth/Register/RegisterScreen.dart';
import 'View/Screen/CompleteProfile/CompleteProfileScreen.dart';
import 'View/Screen/Doctor/DoctorHomePage.dart';
import 'View/Screen/Doctor/DoctorEditProfilePage.dart';
import 'View/Screen/Notvications/Notvications.dart';
import 'View/Screen/Patient/PatientHomePage.dart';
import 'View/Screen/Patient/PatientEditProfilePage.dart';
import 'View/Screen/Patient/PatientPaymentPage.dart';
import 'View/Screen/Patient/PatientResourcePage.dart';
import 'View/Screen/Appointment/AppointmentDetailsPage.dart';
import 'View/Screen/Doctor/CreateMedicalRecordPage.dart';
import 'View/Screen/Doctor/CreatePrescriptionPage.dart';
import 'View/Screen/Doctor/DoctorPatientDetailsPage.dart';
import 'View/Screen/Languege.dart';
import 'View/Screen/Splish/SplashScreen.dart';
import 'View/Screen/Auth/Login/Loginpage.dart';
import 'core/constant/Approutes.dart';

//import '../core/localization/translation.dart';
/* import 'package:testproject/core/MiddelWere/mymiddleware%20.dart';
import 'package:testproject/view/screen/Address/Addadress.dart';
import 'package:testproject/view/screen/Address/AddressView.dart';
import 'package:testproject/view/screen/Auth/forgetpassword/ResetPassword.dart';
import 'package:testproject/view/screen/Auth/Signup.dart';
import 'package:testproject/view/screen/Auth/forgetpassword/successresetpassword.dart';
import 'package:testproject/view/screen/Auth/Success_Sginup.dart';
import 'package:testproject/view/screen/Auth/forgetpassword/VerfiyCode.dart';
import 'package:testproject/view/screen/Auth/login.dart';
import 'package:testproject/view/screen/Auth/verfiycodesignup.dart';
import 'package:testproject/view/screen/Cart/cart.dart';
import 'package:testproject/view/screen/Check_out/Check_out.dart';
import 'package:testproject/view/screen/Favorite/FavoritePage.dart';
import 'package:testproject/view/screen/Home/ScreenHome.dart';
import 'package:testproject/view/screen/Items/items.dart';
import 'package:testproject/view/screen/OnBording.dart';
import 'package:testproject/view/screen/Setting/Settingpage.dart';
import 'package:testproject/view/screen/languege.dart';
import 'package:testproject/view/screen/product%20details.dart'; */

//import 'core/constant/Approutes.dart';

final List<GetPage<dynamic>> routes = [
  //Auth
  GetPage(
    name: Approutes.splash,
    page: () => const SplashScreen(),
    binding: SplashBinding(),
  ),
  /*   GetPage(
    name: Approutes.intro,
    page: () => const IntroScreen(),
    binding: IntroBinding(),
  ), */
  GetPage(name: Approutes.language, page: () => const Languege()),

  GetPage(name: Approutes.login, page: () => const LoginPage()),
  GetPage(
    name: Approutes.HomeScreen,
    page: () => const PatientHomePage(),
    binding: PatientHomeBinding(),
  ),
  GetPage(
    name: Approutes.patientEditProfile,
    page: () => const PatientEditProfilePage(),
    binding: PatientHomeBinding(),
  ),
  GetPage(
    name: Approutes.patientResource,
    page: () => const PatientResourcePage(),
    binding: PatientHomeBinding(),
  ),
  GetPage(
    name: Approutes.paymentMethod,
    page: () => const PatientPaymentPage(),
    binding: PatientHomeBinding(),
  ),
  GetPage(
    name: Approutes.paymentSuccess,
    page: () => const PatientPaymentSuccessPage(),
    binding: PatientHomeBinding(),
  ),
  GetPage(name: Approutes.Signup, page: () => RegisterScreen()),
  GetPage(
    name: Approutes.completeProfile,
    page: () => const CompleteProfileScreen(),
    binding: CompleteProfileBinding(),
  ),
  GetPage(
    name: Approutes.doctorHome,
    page: () => const DoctorHomePage(),
    binding: DoctorHomeBinding(),
  ),
  GetPage(
    name: Approutes.doctorEditProfile,
    page: () => const DoctorEditProfilePage(),
    binding: DoctorEditProfileBinding(),
  ),
  GetPage(
    name: Approutes.doctorAppointmentDetails,
    page: () => const AppointmentDetailsPage(),
    binding: DoctorAppointmentDetailsBinding(),
  ),
  GetPage(
    name: Approutes.doctorPatientDetails,
    page: () => const DoctorPatientDetailsPage(),
    binding: DoctorPatientDetailsBinding(),
  ),
  GetPage(
    name: Approutes.createMedicalRecord,
    page: () => const CreateMedicalRecordPage(),
    binding: CreateMedicalRecordBinding(),
  ),
  GetPage(
    name: Approutes.createPrescription,
    page: () => const CreatePrescriptionPage(),
    binding: CreatePrescriptionBinding(),
  ),
  GetPage(name: Approutes.Notvications, page: () => const Notvications()),
  /*   GetPage(name: Approutes.VarfiyCode, page: () => const VerfiyCode()),
  GetPage(name: Approutes.ResetPassword, page: () => const Resetpassword()),
  GetPage(
    name: Approutes.SuccessReSetPassword,
    page: () => const SuccessResetPassrord(),
  ),
  GetPage(name: Approutes.SuccessSignup, page: () => const SuccessSignup()),
  GetPage(
    name: Approutes.VarfiyCodeSginUp,
    page: () => const VerfiyCodeSginUp(),
  ),
 */
  //OnBoarding
  // GetPage(name: Approutes.OnBoarding, page: () => const OnBoarding()),

  //home/*
  // GetPage(name: Approutes.HomeScreen, page: () => const HomeScreen()),

  //items
  /* GetPage(name: Approutes.items, page: () => const Items()),

  //Productdetails
  GetPage(name: Approutes.Productdetails, page: () => const Productdetails()),

  //Favorite
  GetPage(
    name: Approutes.Favoritepage,
    page: () => const Favoritepage(),
    binding: initialBinding(),
  ),

  //Setting
  GetPage(name: Approutes.Settingpage, page: () => const Setting()),

  //cart
  GetPage(name: Approutes.Cart, page: () => const Cart()),

  //Addressview
  GetPage(name: Approutes.Addressview, page: () => const Addressview()),

  GetPage(name: Approutes.Addaddress, page: () => const Addaddress()),
  GetPage(name: Approutes.CheckOut, page: () => const CheckOut()), */
];
