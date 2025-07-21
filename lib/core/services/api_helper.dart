import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../features/data/datasources/local_datasource.dart';
import '../../features/data/models/common/base_request.dart';
import '../../utils/app_constants.dart';
import '../configs/app_config.dart';
import '../configs/token_interceptor.dart';
import '../network/network_config.dart';

class APIHelper {
  late final Dio dio;
  final LocalDatasource? localDatasource;

  APIHelper({Dio? dio, this.localDatasource}) {
    this.dio = dio ?? Dio();
    _initApiClient();
  }

  void _initApiClient() {
    final logInterceptor = LogInterceptor(
      responseHeader: true,
      requestHeader: true,
    );

    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: kConnectionTimeout),
      receiveTimeout: const Duration(seconds: kReceiveTimeout),
      persistentConnection: true,
      baseUrl: NetworkConfig.getNetworkUrl(),
      headers: {'Authorization': AppConstants.accessToken},
    );

    dio.interceptors.clear();
    dio.interceptors.add(TokenInterceptor(localDataSource: localDatasource, dio: dio));
    dio.interceptors.add(logInterceptor);

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (
            X509Certificate cert,
            String host,
            int port,
            ) {
          log(cert.endValidity.isAfter(DateTime.now()).toString());
          return true; // Accept all certificates (for dev)
        };
        return client;
      },
      validateCertificate: (cert, host, port) {
        if (kIsSSLAvailable) {
          // return isTrustedCertificate(cert, host);
          return true;
        } else {
          return true;
        }
      },
    );
  }

  Future<Response?> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      log('[API Helper - GET] Request Query => $queryParameters');
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
      );
      log('[API Helper - GET] Response Body => ${response.data}');
      return response;
    } catch (e) {
      _handleError(e, method: 'GET');
      rethrow;
    }
  }

  Future<dynamic> post(String url, {required Map<String, dynamic> data}) async {
    try {
      final Map<String, dynamic> bodyData = await _generateBaseRequestData(data);
      log('[API Helper - POST] Request Body => $bodyData');
      final response = await dio.post(
        url,
        data: bodyData,
      );
      if (response.data == "" || response.data == null) {
        throw Exception("Something went wrong!");
      } else {
        log('[API Helper - POST] Response Body => ${response.data}');
        return response.data;
      }
    } catch (e) {
      if (e is DioException) {
        final errorResponse = e.response?.data;
        final statusCode = e.response?.statusCode;

        log("[API Helper - POST] Error Status Code => $statusCode");
        log("[API Helper - POST] Error Response => $errorResponse");

        if (errorResponse is Map<String, dynamic> &&
            errorResponse.containsKey('success') &&
            errorResponse.containsKey('message') &&
            errorResponse.containsKey('data') &&
            errorResponse.containsKey('errors') &&
            errorResponse.containsKey('errorCode') &&
            errorResponse.containsKey('responseTime') &&
            errorResponse['success'] is bool &&
            errorResponse['message'] is String &&
            (errorResponse['data'] == null ||
                errorResponse['data'] is Map<String, dynamic>) &&
            (errorResponse['errors'] == null ||
                errorResponse['errors'] is List) &&
            errorResponse['errorCode'] is int &&
            errorResponse['responseTime'] is String) {
          return errorResponse;
        }

        return {
          "success": false,
          "message":
          e.type == DioExceptionType.receiveTimeout
              ? "Connection timed out. Please check your network and retry"
              : e.type == DioExceptionType.connectionError
              ? "Unable to connect to the server. Please check your internet connection and try again"
              : "Something went wrong !",
        };
      } else if (e is HttpException) {
        log("[API Helper - POST] Error Status Uri => ${e.uri}");
        log("[API Helper - POST] Error msg => ${e.message}");
        return {"message": e.message};
      } else {
        log("[API Helper - POST] Connection Exception => $e");
        log("[API Helper - POST] Error type => ${e.runtimeType}");
        return {"message": e.toString()};
      }
    }
  }

  dynamic _handleError(dynamic e, {required String method}) {
    if (e is DioException) {
      final errorResponse = e.response;
      final statusCode = e.response?.statusCode;
      log("[API Helper - $method] Error Status Code => $statusCode");
      log("[API Helper - $method] Error Response => $errorResponse");
      return {
        "success": false,
        "message": e.type == DioExceptionType.receiveTimeout
            ? "Connection timed out. Please check your network and retry"
            : e.type == DioExceptionType.connectionError
            ? "Unable to connect to the server. Please check your internet connection and try again"
            : "Something went wrong!",
      };
    } else if (e is HttpException) {
      log("[API Helper - $method] Error Status Uri => ${e.uri}");
      log("[API Helper - $method] Error msg => ${e.message}");
      return {"message": e.message};
    } else {
      log("[API Helper - $method] Connection Exception => $e");
      log("[API Helper - $method] Error type => ${e.runtimeType}");
      return {"message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> _generateBaseRequestData(
      Map<String, dynamic> body,
      ) async {
    BaseRequest baseRequest = BaseRequest();
    baseRequest.channel = kDeviceChannel;
    baseRequest.ip = '1.1.1.1';
    baseRequest.userAgent = 'FWFW';
    baseRequest.username = AppConstants.username;
    body.addAll(baseRequest.toJson());
    return body;
  }
}