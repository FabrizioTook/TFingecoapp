import 'package:finanzas/shared/models/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;

  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}
