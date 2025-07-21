import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:dartz/dartz.dart';

import '../../data/models/common/base_response.dart';
import '../../data/models/requests/login.dart';
import '../../data/models/responses/login.dart';

abstract class Repository {
  Future<Either<dynamic, BaseResponse<LoginResponse>>> login(
      LoginRequest params);
}