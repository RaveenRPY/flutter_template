import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/data/models/responses/login.dart';
import 'package:AventaPOS/features/data/models/responses/sale/get_stock.dart';
import 'package:dartz/dartz.dart';
import '../../../core/network/network_info.dart';
import '../../../utils/app_strings.dart';
import '../../domain/respositories/repository.dart';
import '../datasources/remote_datasource.dart';
import '../models/common/base_response.dart';

class RepositoryImpl implements Repository {
  final RemoteDataSource? remoteDataSource;
  final NetworkInfo? networkInfo;

  RepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  /// Splash
  @override
  Future<Either<dynamic, BaseResponse<LoginResponse>>> login(
    LoginRequest params,
  ) async {
    if (await networkInfo!.isConnected) {
      try {
        final parameters = await remoteDataSource!.login(params);
        return Right(parameters);
      } catch (e) {
        return Left(e);
      }
    } else {
      return Left(AppStrings.noInternetErrorMsg);
    }
  }
  /// Get Stock
  @override
  Future<Either<dynamic, BaseResponse<GetStockResponse>>> getStock(
    CommonRequest params,
  ) async {
    if (await networkInfo!.isConnected) {
      try {
        final parameters = await remoteDataSource!.getStock(params);
        return Right(parameters);
      } catch (e) {
        return Left(e);
      }
    } else {
      return Left(AppStrings.noInternetErrorMsg);
    }
  }
}
