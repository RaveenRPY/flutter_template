import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/responses/cash_in_out/view_cash_in_out.dart';
import 'package:dartz/dartz.dart';

import '../../../data/models/common/base_response.dart';
import '../../respositories/repository.dart';
import '../usecase.dart';

class ViewTodayCashInOutUseCase
    extends UseCase<BaseResponse<ViewCashInOutResponse>, CommonRequest> {
  final Repository? repository;

  ViewTodayCashInOutUseCase({this.repository});

  @override
  Future<Either<dynamic, BaseResponse<ViewCashInOutResponse>>> call(
      CommonRequest params) async {
    return await repository!.viewTodayCashInOut(params);
  }
}
