import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../View/Screen/Home/PatientHomePage.dart';
import '../../View/Screen/Notvications/Notvications.dart';
import '../../View/Screen/Profile/Profile.dart';
import '../../View/Screen/Setting/Setting.dart';

abstract class HomeScreenOfPatint_controller extends GetxController {
  changepage(int currentpage);
}

class HomeScreenOfPatint_controllerImp extends HomeScreenOfPatint_controller {
  int currenttpage = 0;

  List<Widget> Listpage = [
    const PatientHomePage(),
    const Notvications(),
    const ProfileScreen(),
    const Setting(),
  ];

  List buttonappbar = [
    {"title": "Home", "icon": Icons.home},
    {"title": "Notis", "icon": Icons.notifications_active_outlined},
    {"title": "ProfileScreen", "icon": Icons.person},
    {"title": "settings", "icon": Icons.settings},
  ];
  @override
  void changepage(int i) {
    currenttpage = i;
    update();
  }
}
