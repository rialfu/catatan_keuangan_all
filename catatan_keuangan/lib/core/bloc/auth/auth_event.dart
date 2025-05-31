import 'package:catatan_keuangan/core/model/login_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LoginRequestedWithBiometric extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedWithBiometric(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CleanAuthRequest extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final LoginModel data;
  const RegisterRequested(this.data);
  @override
  List<Object?> get props => [data];
}
