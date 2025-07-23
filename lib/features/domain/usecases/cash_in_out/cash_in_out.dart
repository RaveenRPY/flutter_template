import 'package:AventaPOS/features/data/models/requests/cash_in_out.dart';
import 'package:dartz/dartz.dart';

import '../../../data/models/common/base_response.dart';
import '../../respositories/repository.dart';
import '../usecase.dart';

class CashInOutUseCase
    extends UseCase<BaseResponse<Serializable>, CashInOutRequest> {
  final Repository? repository;

  CashInOutUseCase({this.repository});

  @override
  Future<Either<dynamic, BaseResponse<Serializable>>> call(
      CashInOutRequest params) async {
    return await repository!.cashInOut(params);
  }
}
