import 'package:dartz/dartz.dart';

import '../../../data/models/common/base_response.dart';
import '../../../data/models/requests/login.dart';
import '../../../data/models/responses/login.dart';
import '../../respositories/repository.dart';
import '../usecase.dart';

class LoginUseCase
    extends UseCase<BaseResponse<LoginResponse>, LoginRequest> {
  final Repository? repository;

  LoginUseCase({this.repository});

  @override
  Future<Either<dynamic, BaseResponse<LoginResponse>>> call(
      LoginRequest params) async {
    return await repository!.login(params);
  }
}
