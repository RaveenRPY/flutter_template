import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../utils/app_constants.dart';
import '../../features/data/datasources/local_datasource.dart';

class TokenInterceptor extends Interceptor {
  final LocalDatasource? localDataSource;
  final Dio? dio;

  TokenInterceptor({this.localDataSource, this.dio});

  @override
  Future<void> onRequest(options, handler) async {
    if (false) {
      options.headers['Authorization'] = null;
    } else {
      final String? accessToken = await localDataSource!.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {

        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(response, handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException dioError, handler) {
    return handler.next(dioError);
  }
}
