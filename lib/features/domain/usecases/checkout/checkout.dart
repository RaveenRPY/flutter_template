import 'package:AventaPOS/features/data/models/requests/checkout.dart';
import 'package:AventaPOS/features/data/models/responses/checkout/checkout.dart';
import 'package:dartz/dartz.dart';

import '../../../data/models/common/base_response.dart';
import '../../../data/models/requests/login.dart';
import '../../../data/models/responses/login.dart';
import '../../respositories/repository.dart';
import '../usecase.dart';

class CheckOutUseCase
    extends UseCase<BaseResponse<CheckOutResponse>, CheckOutRequest> {
  final Repository? repository;

  CheckOutUseCase({this.repository});

  @override
  Future<Either<dynamic, BaseResponse<CheckOutResponse>>> call(
      CheckOutRequest params) async {
    return await repository!.checkout(params);
  }
}
