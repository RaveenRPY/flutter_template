import 'dart:developer';
import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/domain/usecases/login/login.dart';
import 'package:AventaPOS/features/domain/usecases/stock/get_stock.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/msg_types.dart';
import 'package:bloc/bloc.dart';

import '../../../data/datasources/local_datasource.dart';
import '../../../data/models/common/base_response.dart';
import '../base_bloc.dart';

class StockBloc extends BaseBloc<StockEvent, BaseState<StockState>> {
  final GetStockUseCase? getStockUseCase;

  StockBloc({this.getStockUseCase}) : super(StockInitial()) {
    on<GetStockEvent>(_onGetStockEvent);
  }

  Future<void> _onGetStockEvent(
    GetStockEvent event,
    Emitter<BaseState<StockState>> emit,
  ) async {
    try {
      emit(APILoadingState());

      final response = await getStockUseCase!(CommonRequest(
        message: kGetStock,
      ));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {
              return GetStockFailedState(errorMsg: l.message);
            } else {
              return GetStockFailedState(errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              log("------------ ${r.data?.stock?[0].item?.description}");
              AppConstants.stockList = r.data?.stock;
              return GetStockSuccessState(message: r.message,stockList: r.data?.stock);
            } else {
              log(r.message.toString());
              return GetStockFailedState(errorMsg: r.message);
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }
}
