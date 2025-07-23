import 'package:AventaPOS/features/domain/usecases/cash_in_out/view_cash_in_out.dart';
import 'package:AventaPOS/features/domain/usecases/checkout/checkout.dart';
import 'package:AventaPOS/features/domain/usecases/login/login.dart';
import 'package:AventaPOS/features/domain/usecases/stock/get_stock.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_bloc.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/data/datasources/local_datasource.dart';
import '../../features/data/datasources/remote_datasource.dart';
import '../../features/data/repositories/repository_impl.dart';
import '../../features/domain/respositories/repository.dart';
import '../../features/domain/usecases/cash_in_out/cash_in_out.dart';
import '../../features/presentation/bloc/sale/sale_bloc.dart';
import 'api_helper.dart';
import '../network/network_info.dart';

final inject = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // Core Services
  inject.registerSingleton(DeviceInfoPlugin());
  inject.registerLazySingleton(() => sharedPreferences);
  inject.registerLazySingleton(() => packageInfo);

  // Network Services
  inject.registerSingleton(Dio());
  inject.registerLazySingleton(() => Connectivity());
  inject.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(inject()));

  // Data Sources
  inject.registerLazySingleton<LocalDatasource>(
    () => LocalDatasource(
      sharedPreferences: inject(),
    ),
  );

  inject.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(apiHelper: inject()),
  );

  // API Helper
  inject.registerLazySingleton<APIHelper>(
    () => APIHelper(
      dio: inject(),
      localDatasource: inject(),
    ),
  );

  // Repository
  inject.registerLazySingleton<Repository>(
    () => RepositoryImpl(remoteDataSource: inject(), networkInfo: inject()),
  );

  // Use Cases
  inject.registerLazySingleton(
    () => LoginUseCase(repository: inject()),
  );
  inject.registerLazySingleton(
    () => GetStockUseCase(repository: inject()),
  );
  inject.registerLazySingleton(
    () => CheckOutUseCase(repository: inject()),
  );
  inject.registerLazySingleton(
    () => ViewTodayCashInOutUseCase(repository: inject()),
  );
  inject.registerLazySingleton(
    () => CashInOutUseCase(repository: inject()),
  );

  // BLoCs - Using Factory for stateful BLoCs
  inject.registerFactory(
    () => LoginBloc(
      loginUseCase: inject<LoginUseCase>(),
      localDatasource: inject<LocalDatasource>(),
    ),
  );
  inject.registerFactory(
    () => StockBloc(
      getStockUseCase: inject<GetStockUseCase>(),
      checkOutUseCase: inject<CheckOutUseCase>(),
      viewTodayCashInOutUseCase: inject<ViewTodayCashInOutUseCase>(),
      cashInOutUseCase: inject<CashInOutUseCase>(),
    ),
  );

  inject.registerFactory(
    () => SaleBloc(),
  );
}
