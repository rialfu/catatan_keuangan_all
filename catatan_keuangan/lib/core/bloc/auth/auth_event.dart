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

class LoginWithGoogleSSO extends AuthEvent {
  final String idToken;
  final String email;
  const LoginWithGoogleSSO(this.idToken, this.email);
  @override
  List<Object?> get props => [idToken];
}

class RegisterWithGoogleSSO extends AuthEvent {
  final String idToken;
  final String email;
  final String name;
  final String password;
  const RegisterWithGoogleSSO(
    this.idToken,
    this.email,
    this.name,
    this.password,
  );
  @override
  List<Object?> get props => [idToken, email, name, password];
}

class LogoutRequested extends AuthEvent {}

class CleanAuthRequest extends AuthEvent {}

class CleanAuthRequestRegister extends AuthEvent {
  final String idToken;
  final String email;
  const CleanAuthRequestRegister(
    this.idToken,
    this.email,
  );
  @override
  List<Object?> get props => [idToken, email];
}

class RegisterRequested extends AuthEvent {
  final LoginModel data;
  const RegisterRequested(this.data);
  @override
  List<Object?> get props => [data];
}
