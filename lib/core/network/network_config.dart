import '../../utils/enums.dart';
import '../configs/app_config.dart';

const kConnectionTimeout = 10;
const kReceiveTimeout = 5;

class IPAddress {
  /// Replace from your IPs or Urls
  static const String QA = '147.93.157.141:9090/';
  static const String DEV = '147.93.157.141:9090/';
  static const String UAT = '147.93.157.141:9090/';
  static const String LIVE = '147.93.157.141:9090/';
}

class ServerProtocol {
  /// Replace from your each protocols
  static const String QA = 'http://';
  static const String DEV = 'http://';
  static const String UAT = 'http://';
  static const String LIVE = 'http://';
}

class ContextRoot {
  /// Replace from your root path
  static const String QA = 'auth/api/v1/';
  static const String DEV = 'auth/api/v1/';
  static const String UAT = 'auth/api/v1/';
  static const String LIVE = 'auth/api/v1/';
}

class NetworkConfig {
  static String getNetworkUrl() {
    String url = _getProtocol() + _getIP() + _getContextRoot();
    return url;
  }

  static String _getContextRoot() {
    if (kFlavor == Flavor.QA) {
      return ContextRoot.QA;
    } else if (kFlavor == Flavor.DEV) {
      return ContextRoot.DEV;
    } else if (kFlavor == Flavor.UAT) {
      return ContextRoot.UAT;
    } else {
      return ContextRoot.LIVE;
    }
  }

  static String _getProtocol() {
    if (kFlavor == Flavor.QA) {
      return ServerProtocol.QA;
    } else if (kFlavor == Flavor.DEV) {
      return ServerProtocol.DEV;
    } else if (kFlavor == Flavor.UAT) {
      return ServerProtocol.UAT;
    } else {
      return ServerProtocol.LIVE;
    }
  }

  static String _getIP() {
    if (kFlavor == Flavor.QA) {
      return IPAddress.QA;
    } else if (kFlavor == Flavor.DEV) {
      return IPAddress.DEV;
    } else if (kFlavor == Flavor.UAT) {
      return IPAddress.UAT;
    } else {
      return IPAddress.LIVE;
    }
  }
}

class APIResponse {
  /// Maintain responses codes
  static const String RESPONSE_LOGIN_SUCCESS = "1001";
}
