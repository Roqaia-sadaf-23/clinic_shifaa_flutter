import '/core/Error/Failure.dart';
import '/core/services/serveses.dart';
import '/data/datasource/remote/Home/HomeData.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchMIXController extends GetxController {
  Failure? failure;

  TextEditingController? search;
  bool isSearch = false;

  HomeData homeData = HomeData(Get.find());

  checksearch(val) {
    if (val == "") {
      failure = null;
      isSearch = false;
      update();
    }
  }

  oncearchItem() {
    isSearch = true;
    update();
  }

  GotoFavoritePage() {}
}

abstract class HomeController extends SearchMIXController {
  ItemsDatawithdescunt();
  CategoryData();
  Gotoitmes(List categorles, int selectedcat, int CatogoryID);
  GotopageProductdetails(var ItesModel);
}

class PatientHomeControllerImp extends HomeController {
  Myservices myservices = Get.find();

  final GlobalKey<FormState> formstate = GlobalKey<FormState>();

  List Categorydata = [];
  List Itemsdata = [];

  HomeData homeData = HomeData(Get.find());

  @override
  void onInit() {
    search = TextEditingController();
    ItemsDatawithdescunt();
    CategoryData();
    super.onInit();
  }

  @override
  CategoryData() async {
    failure = null;
    update();

    var response = await homeData.getdata();

    print("== Category Response from API ==");
    print(response);

    response.fold(
      (fail) {
        failure = fail;
      },
      (data) {
        Categorydata.clear();

        if (data is List) {
          Categorydata.addAll(data);
        } else if (data is Map && data["value"] is List) {
          Categorydata.addAll(data["value"]);
        }

        failure = null;
      },
    );

    update();
  }

  @override
  ItemsDatawithdescunt() async {
    failure = null;
    update();

    var response = await homeData.GetAllcateforyItemswithdescount();

    print("== Items Response from API ==");
    print(response);

    response.fold(
      (fail) {
        failure = fail;
      },
      (data) {
        Itemsdata.clear();

        if (data is List) {
          Itemsdata.addAll(data);
        } else if (data is Map && data["value"] is List) {
          Itemsdata.addAll(data["value"]);
        }

        failure = null;
      },
    );

    update();
  }

  @override
  Gotoitmes(categorles, selectedcat, CatogoryID) {}

  @override
  GotopageProductdetails(ItesModel) {
    print("🟢 Sending to Productdetails: $ItesModel");
  }
}
