import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/common/base_response.dart';

abstract class Repository {
  Future<Either<dynamic, BaseResponse<LoginResponse>>> login(
      LoginRequest params);

  Future<Either<dynamic, BaseResponse<GetStockResponse>>> getStock(
      CommonRequest params);
}
