import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkChecker {
  static Future<bool> hasInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      final hasConnection =
          await InternetConnectionChecker.instance.hasConnection;

      return hasConnection;
    } catch (e) {
      print("Network Error: $e");
      return false;
    }
  }
}
