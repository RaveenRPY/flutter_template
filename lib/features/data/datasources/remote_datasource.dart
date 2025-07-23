import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/cash_in_out.dart';
import 'package:AventaPOS/features/data/models/requests/checkout.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/cash_in_out/view_cash_in_out.dart';
import 'package:AventaPOS/features/data/models/responses/checkout/checkout.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';

import '../../../core/services/api_helper.dart';
import '../models/common/base_response.dart';
import '../models/responses/login.dart';

abstract class RemoteDataSource {
  Future<BaseResponse<LoginResponse>> login(LoginRequest request);
  Future<BaseResponse<GetStockResponse>> getStock(CommonRequest request);
  Future<BaseResponse<CheckOutResponse>> checkout(CheckOutRequest request);
  Future<BaseResponse<ViewCashInOutResponse>> viewTodayCashInOut(CommonRequest request);
  Future<BaseResponse<Serializable>> cashInOut(CashInOutRequest request);
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
  ///Checkout
  @override
  Future<BaseResponse<CheckOutResponse>> checkout(CheckOutRequest request) async {
    try {
      final response = await apiHelper.post(
        'billing/api/v1/billing/checkout',
        data: request.toJson(),
      );

      return BaseResponse<CheckOutResponse>.fromJson(
        response,
        (data) => CheckOutResponse.fromJson(data ?? {}),
      );
    } on Exception {
      rethrow;
    }
  }
  ///View Cash In / Out
  @override
  Future<BaseResponse<ViewCashInOutResponse>> viewTodayCashInOut(CommonRequest request) async {
    try {
      final response = await apiHelper.post(
        'billing/api/v1/billing/today-cash-in-out',
        data: request.toJson(),
      );

      return BaseResponse<ViewCashInOutResponse>.fromJson(
        response,
        (data) => ViewCashInOutResponse.fromJson(data ?? {}),
      );
    } on Exception {
      rethrow;
    }
  }

  ///Cash In Out
  @override
  Future<BaseResponse<Serializable>> cashInOut(CashInOutRequest request) async {
    try {
      final response = await apiHelper.post(
        'billing/api/v1/billing/cash-in-out',
        data: request.toJson(),
      );

      return BaseResponse.fromJson(response, (_) {});
    } on Exception {
      rethrow;
    }
  }
}
