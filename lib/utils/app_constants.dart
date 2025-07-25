import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

/// UI ->  Margin, Opacity, Width
const double kLeftRightMarginOnBoarding = 20;
const double kLeftRightMargin = 16;
const double kTopMarginOnBoarding = 32;
const double kBottomMargin = 20;
const double kOnBoardingMarginBetweenFields = 25;

const kAppName = 'AventaPOS';
const kDeviceChannel = 'OP';

class AppConstants {
  static String kBaseUrl = 'http://147.93.157.141:9090/';
  static String? username;
  static String? accessToken;
  static bool IS_USER_LOGGED = false;
  static bool kIsSSLAvailable = false;

  static LoginResponse? profileData = LoginResponse();
  static List<Stock>? stockList;

  static void clearAllUserData() {
    accessToken = null;
    IS_USER_LOGGED = false;
    stockList = null;
    profileData = LoginResponse();
    username = null;
  }
}
