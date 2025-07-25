import 'dart:developer';
import 'package:AventaPOS/features/data/models/common/common_request.dart';
import 'package:AventaPOS/features/data/models/requests/cash_in_out.dart';
import 'package:AventaPOS/features/data/models/requests/checkout.dart';
import 'package:AventaPOS/features/domain/usecases/cash_in_out/view_cash_in_out.dart';
import 'package:AventaPOS/features/domain/usecases/checkout/checkout.dart';
import 'package:AventaPOS/features/domain/usecases/stock/get_stock.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_event.dart';
import 'package:AventaPOS/features/presentation/bloc/stock/stock_state.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/msg_types.dart';
import 'package:bloc/bloc.dart';

import '../../../data/models/common/base_response.dart';
import '../../../domain/usecases/cash_in_out/cash_in_out.dart';
import '../base_bloc.dart';

class StockBloc extends BaseBloc<StockEvent, BaseState<StockState>> {
  final GetStockUseCase? getStockUseCase;
  final CheckOutUseCase? checkOutUseCase;
  final ViewTodayCashInOutUseCase? viewTodayCashInOutUseCase;
  final CashInOutUseCase? cashInOutUseCase;

  StockBloc(
      {this.getStockUseCase,
      this.checkOutUseCase,
      this.viewTodayCashInOutUseCase,
      this.cashInOutUseCase})
      : super(StockInitial()) {
    on<GetStockEvent>(_onGetStockEvent);
    on<CheckOutEvent>(_onCheckOutEvent);
    on<ViewTodayCashInOutEvent>(_onViewTodayCashInOutEvent);
    on<CashInOutEvent>(_onCashInOutEvent);
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
              return GetStockSuccessState(
                  message: r.message, stockList: r.data?.stock);
            } else {
              if (r.errorCode == 401 || r.errorCode == 403) {
                return TokenInvalidState(error: r.message);
              } else {
                return GetStockFailedState(errorMsg: r.message);
              }
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }

  Future<void> _onCheckOutEvent(
    CheckOutEvent event,
    Emitter<BaseState<StockState>> emit,
  ) async {
    try {
      emit(APILoadingState());

      final response = await checkOutUseCase!(CheckOutRequest(
        message: kCheckout,
        cashierUser: AppConstants.username,
        remark: event.remark,
        customer: 1,
        paymentType: event.paymentType,
        salesType: event.salesType,
        payAmount: event.payAmount,
        totalAmount: event.totalAmount,
        billingItem: event.billingItem,
      ));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {
              return CheckoutFailedState(errorMsg: l.message);
            } else {
              return CheckoutFailedState(errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              return CheckoutSuccessState(response: r.data, msg: r.message);
            } else {
              if (r.errorCode == 401 || r.errorCode == 403) {
                return TokenInvalidState(error: r.message);
              } else {
                return CheckoutFailedState(errorMsg: r.message);
              }
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }

  Future<void> _onViewTodayCashInOutEvent(
    ViewTodayCashInOutEvent event,
    Emitter<BaseState<StockState>> emit,
  ) async {
    try {
      emit(ViewTodayCashInOutLoadingState());

      final response = await viewTodayCashInOutUseCase!(
          CommonRequest(message: kViewCashInOut));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {
              return ViewTodayCashInOutFailedState(errorMsg: l.message);
            } else {
              return ViewTodayCashInOutFailedState(errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              return ViewTodayCashInOutSuccessState(
                  dataList: r.data?.cash, msg: r.message);
            } else {
              if (r.errorCode == 401 || r.errorCode == 403) {
                return TokenInvalidState(error: r.message);
              } else {
                return ViewTodayCashInOutFailedState(errorMsg: r.message);
              }
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }

  Future<void> _onCashInOutEvent(
    CashInOutEvent event,
    Emitter<BaseState<StockState>> emit,
  ) async {
    try {
      emit(CashInOutLoadingState());

      final response = await cashInOutUseCase!(CashInOutRequest(
          message: kCashInOut,
          remark: event.remark,
          amount: event.amount,
          cashInOut: event.cashInOut));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {
              return CashInOutFailedState(errorMsg: l.message);
            } else {
              return CashInOutFailedState(errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              return CashInOutSuccessState(
                  msg: r.message);
            } else {
              if (r.errorCode == 401 || r.errorCode == 403) {
                return TokenInvalidState(error: r.message);
              } else {
                return CashInOutFailedState(errorMsg: r.message);
              }
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }
}
