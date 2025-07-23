import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/cash_in_out.dart';
import 'package:AventaPOS/features/data/models/requests/checkout.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/checkout/checkout.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/common/base_response.dart';
import '../../data/models/responses/cash_in_out/view_cash_in_out.dart';

abstract class Repository {
  Future<Either<dynamic, BaseResponse<LoginResponse>>> login(
      LoginRequest params);
  Future<Either<dynamic, BaseResponse<GetStockResponse>>> getStock(
      CommonRequest params);
  Future<Either<dynamic, BaseResponse<CheckOutResponse>>> checkout(
      CheckOutRequest params);
  Future<Either<dynamic, BaseResponse<ViewCashInOutResponse>>> viewTodayCashInOut(
      CommonRequest params);
  Future<Either<dynamic, BaseResponse<Serializable>>> cashInOut(
      CashInOutRequest params);
}
