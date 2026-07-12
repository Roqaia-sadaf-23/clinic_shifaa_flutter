import '../View/Screen/Languege.dart';
import '../core/MiddelWere/mymiddleware%20.dart';
import 'package:get/get.dart';

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

List<GetPage<dynamic>>? routes = [
  //Auth
  GetPage(
    name: "/",
    page: () => const Languege(),
    middlewares: [MyMiddleWare()],
  ),

  GetPage(name: Approutes.login, page: () => const LoginPage()),
  //GetPage(name: Approutes.Signup, page: () => const Signup()),
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
