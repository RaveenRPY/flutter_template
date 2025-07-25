import 'dart:developer';

import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/domain/usecases/login/login.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_event.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_state.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/msg_types.dart';
import 'package:bloc/bloc.dart';

import '../../../data/datasources/local_datasource.dart';
import '../../../data/models/common/base_response.dart';
import '../base_bloc.dart';

class LoginBloc extends BaseBloc<LoginEvent, BaseState<LoginState>> {
  final LoginUseCase? loginUseCase;
  final LocalDatasource? localDatasource;

  LoginBloc({this.loginUseCase, this.localDatasource}) : super(LoginInitial()) {
    on<CashierLoginEvent>(_onCashierLoginEvent);
  }

  Future<void> _onCashierLoginEvent(
    CashierLoginEvent event,
    Emitter<BaseState<LoginState>> emit,
  ) async {
    try {
      emit(APILoadingState());

      AppConstants.username = event.username;
      final response = await loginUseCase!(LoginRequest(
        message: kLoginRequest,
        password: event.password,
      ));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {
              return LoginFailedState(
                   errorMsg: l.message);
            } else {
              return LoginFailedState(
                   errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              if (r.data!.accessToken != null) {
                localDatasource!.setAccessToken(r.data!.accessToken!);
              }
              AppConstants.IS_USER_LOGGED = true;
              AppConstants.profileData = r.data;

              return LoginSuccessState(message: r.message, isOpening: r.data?.opening);
            } else {
              if (r.errorCode == 401 || r.errorCode == 403) {
                return TokenInvalidState(error: r.message);
              } else {
                return LoginFailedState(errorMsg: r.message);
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
