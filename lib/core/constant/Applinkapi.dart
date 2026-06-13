class Applinkapi {
  static const String publicApiLink = "http://192.168.8.4:5210/api";
  static const String server = "$publicApiLink/eccomerce";
  static const String getimageStatic = "$publicApiLink/Images/GetImage";
  static const String AllCat = "$publicApiLink/Categorles";
  static const String StaticItems = "$publicApiLink/Items";
  //static const String staticfavorite = "$publicApiLink/Favorete/delete/favoriteid";
  static const String staticCart = "$publicApiLink/Cart";
  //=======================Images==========================
  /* static const String imageCategores ="";
static const String imageItems ="";
 */

  static const String testphoto =
      "$getimageStatic/7fecaa6c-e424-4018-9a96-a4d4984f601c.png";

  //=============================================================
  static const String getallusers = "$server/All";
  static const String getuserbyid = "$server/GetById";

  //===========================Auth===========================
  static const String adduser = "$server/Add";
  static const String login = "$server/login";

  //===========================ForgetPassword===========================
  static const String ResetPassword = "$server/ResetPassword";

  //Categorles
  static const String CategorlesData = "$AllCat/AllCategorles";
  //Items
  // ignore: constant_identifier_names
  static const String AllItems = "$StaticItems/AllItems";
  static const String GetAllcateforyItemswithdescount =
      "$StaticItems/AllItemsWithDescount";
  static const String GetItemsByCategoryId = "$StaticItems/category";
  // حذف عبر  //
  // =====================================Favorite========
  // favoriteID
  static const String FavoriteDeleteByFavoriteID =
      "$publicApiLink/Favorete/delete/favoriteid";
  // حذف عبر item + user
  static const String FavoriteDeleteByItemUser = "$publicApiLink/delete/item";

  static const String FavoriteAdd = "$publicApiLink/Favorete/Add";

  static const String GetFavoritebyuserid = "$publicApiLink/Favorete/userid";
  static const String GetfavoritesitemsFavoriteID = "$publicApiLink/Favorete";

  //cart
  static const String CartAdd = "$staticCart/Add";
  static const String CartDelete = "$staticCart";
  static const String GetCartbyItemID = "$staticCart/Items_ID";
  static const String GetCountItems = "$staticCart";
  static const String GetAllCartInfo = "$staticCart/All";
  static const String GetTatalByuserID = "$staticCart/GetTatalByuserID";

  //search

  static const String search = "$StaticItems/FelterItemName";
}

//http://192.168.8.145:5090/api/Items/FelterItemName/
