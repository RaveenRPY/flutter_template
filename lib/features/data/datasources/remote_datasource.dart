import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

import '../../../core/services/api_helper.dart';
import '../models/common/base_response.dart';
import '../models/responses/login.dart';

abstract class RemoteDataSource {
  Future<BaseResponse<LoginResponse>> login(LoginRequest request);
  Future<BaseResponse<GetStockResponse>> getStock(CommonRequest request);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final APIHelper apiHelper;

  RemoteDataSourceImpl({required this.apiHelper});

  ///Login
  @override
  Future<BaseResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await apiHelper.post(
        'auth/api/v1/auth/login',
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
  ///Get Stocks
  @override
  Future<BaseResponse<GetStockResponse>> getStock(CommonRequest request) async {
    try {
      final response = await apiHelper.post(
        'billing/api/v1/billing/stock-list',
        data: request.toJson(),
      );

      return BaseResponse<GetStockResponse>.fromJson(
        response,
        (data) => GetStockResponse.fromJson(data ?? {}),
      );
    } on Exception {
      rethrow;
    }
  }
}
