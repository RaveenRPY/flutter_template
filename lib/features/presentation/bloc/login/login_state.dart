import '../base_bloc.dart';

abstract class LoginState extends BaseState<LoginState> {}

class LoginInitial extends LoginState {}

class LoginSuccessState extends LoginState {
  final String? message;

  LoginSuccessState({this.message});
}

class LoginFailedState extends LoginState {
  final int? errorCode;
  final String? errorMsg;

  LoginFailedState({this.errorCode,this.errorMsg});
}
