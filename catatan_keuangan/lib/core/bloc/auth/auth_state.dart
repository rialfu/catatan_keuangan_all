import '../../enum/auth_enum.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isFirstEntry;
  final AuthError? error;
  final String? name;

  const AuthState({
    this.status = AuthStatus.guest,
    this.isFirstEntry = false,
    this.error,
    this.name,
  });
  const AuthState._({
    this.status = AuthStatus.unknown,
    this.isFirstEntry = true,
    this.error,
    this.name,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated({String? newName})
      : this._(
          status: AuthStatus.authenticated,
          isFirstEntry: false,
          name: newName,
        );

  const AuthState.guest()
      : this._(
          status: AuthStatus.guest,
          isFirstEntry: false,
        );

  const AuthState.firstEntry() : this._(status: AuthStatus.guest);

  const AuthState.error({AuthError error = AuthError.unknown})
      : this._(status: AuthStatus.unknown, isFirstEntry: false, error: error);

  AuthState updateName(String? newName) {
    return AuthState._(
      status: status,
      isFirstEntry: isFirstEntry,
      name: newName,
    );
  }

  @override
  List<Object?> get props => [status, isFirstEntry, error, name];
}

class LoginState extends AuthState {
  // final AuthStatus status = AuthStatus.authenticated;
  // final bool isFirstEntry = false;
  // final AuthError? error;
  // final String? name;
  const LoginState({String? newName})
      : super(
          status: AuthStatus.authenticated,
          isFirstEntry: false,
          name: newName,
        );
}

class AuthLoading extends AuthState {
  final bool load = true;
  const AuthLoading();
}
