
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectionChecker;

  NetworkInfoImpl(this.connectionChecker);


  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> connectivityResult = await connectionChecker.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      await Future.delayed(const Duration(milliseconds: 5));
      final List<ConnectivityResult> connectivityResult1 = await connectionChecker.checkConnectivity();
      if (connectivityResult1.contains(ConnectivityResult.wifi) ||
          connectivityResult1.contains(ConnectivityResult.mobile)) {
        return true;
      } else {
        return false;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 5));
      final List<ConnectivityResult> connectivityResult2 = await connectionChecker.checkConnectivity();
      if (connectivityResult2.contains(ConnectivityResult.wifi) ||
          connectivityResult2.contains(ConnectivityResult.mobile)) {
        return true;
      } else {
        return false;
      }
    }
  }
}
