import 'dart:developer';

import 'package:AventaPOS/features/data/models/requests/login.dart';
import 'package:AventaPOS/features/domain/usecases/login/login.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_event.dart';
import 'package:AventaPOS/features/presentation/bloc/login/login_state.dart';
import 'package:AventaPOS/utils/app_constants.dart';
import 'package:AventaPOS/utils/msg_types.dart';
import 'package:bloc/bloc.dart';

import '../../../data/models/common/base_response.dart';
import '../base_bloc.dart';

class LoginBloc extends BaseBloc<LoginEvent, BaseState<LoginState>> {
  final LoginUseCase? loginUseCase;

  LoginBloc({this.loginUseCase}) : super(LoginInitial()) {
    on<CashierLoginEvent>(_onCashierLoginEvent);
  }

  ///Update Profile Image
  Future<void> _onCashierLoginEvent(
    CashierLoginEvent event,
    Emitter<BaseState<LoginState>> emit,
  ) async {
    try {
      emit(APILoadingState());

      AppConstants.username = event.username;
      final response = await loginUseCase!(
          LoginRequest(message: kLoginRequest, password: event.password));

      emit(
        response.fold(
          (l) {
            if (l is BaseResponse) {

              return LoginFailedState(
                  errorCode: l.errorCode, errorMsg: l.message);
            } else {

              return LoginFailedState(
                  errorCode: l.errorCode, errorMsg: l.toString());
            }
          },
          (r) {
            if (r.success!) {
              return LoginSuccessState(message: r.message);
            } else {
              log(r.message.toString());
              return LoginFailedState(
                  errorCode: r.errorCode, errorMsg: r.message);
            }
          },
        ),
      );
    } catch (e) {
      emit(APIFailureState(error: e.toString()));
    }
  }
}
