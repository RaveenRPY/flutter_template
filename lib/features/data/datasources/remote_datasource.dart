import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';

import '../../../core/services/api_helper.dart';
import '../models/common/base_response.dart';
import '../models/responses/login.dart';

abstract class RemoteDataSource {
  Future<BaseResponse<LoginResponse>> login(LoginRequest request);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final APIHelper apiHelper;

  RemoteDataSourceImpl({required this.apiHelper});

  ///Login
  @override
  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await apiHelper.post(
        'auth/login',
        data: request.toJson(),
      );

      return BaseResponse<LoginResponse>.fromJson(
        response,
        (data) => LoginResponse.fromJson(data ?? {}),
      );
    } on Exception {
      rethrow;
    }
  }
}
