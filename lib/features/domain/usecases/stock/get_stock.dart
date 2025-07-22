import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';
import 'package:dartz/dartz.dart';

import '../../../data/models/common/base_response.dart';
import '../../../data/models/requests/login.dart';
import '../../../data/models/responses/login.dart';
import '../../respositories/repository.dart';
import '../usecase.dart';

class GetStockUseCase
    extends UseCase<BaseResponse<GetStockResponse>, CommonRequest> {
  final Repository? repository;

  GetStockUseCase({this.repository});

  @override
  Future<Either<dynamic, BaseResponse<GetStockResponse>>> call(
      CommonRequest params) async {
    return await repository!.getStock(params);
  }
}
