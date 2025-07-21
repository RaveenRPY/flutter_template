import '../base_bloc.dart';

abstract class LoginEvent extends BaseEvent {}

class CashierLoginEvent extends LoginEvent {
  final String username;
  final String password;

  CashierLoginEvent({required this.username, required this.password});
}
