import '../../enum/auth_enum.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isLoad;
  final bool isFirstEntry;
  final AuthError? error;
  final String? name;
  final String email;
  const AuthState({
    this.status = AuthStatus.guest,
    this.isLoad = false,
    this.isFirstEntry = false,
    this.name,
    this.error,
    this.email = '',
  });
  @override
  List<Object?> get props => [
        status,
        isLoad,
        isFirstEntry,
        error,
        email,
        name,
      ];
}

class AuthStateLogin extends AuthState {
  const AuthStateLogin({
    required String setEmail,
    String? setName,
    required bool setLoad,
  }) : super(
          email: setEmail,
          name: setName,
          isLoad: setLoad,
          status: AuthStatus.authenticated,
          isFirstEntry: false,
        );
  AuthStateLogin changeValue({String? setEmail, String? name, bool? isLoad}) {
    return AuthStateLogin(
      setEmail: setEmail ?? email,
      setName: name,
      setLoad: isLoad ?? this.isLoad,
    );
  }
}

class AuthStateGuest extends AuthState {
  const AuthStateGuest({
    required bool setLoad,
    AuthError? setError,
    bool setIsFirstEntry = true,
  }) : super(
          isLoad: setLoad,
          status: AuthStatus.guest,
          isFirstEntry: setIsFirstEntry,
          error: setError,
        );
  AuthStateGuest changeValue({AuthError? setError, bool? setLoad}) {
    return AuthStateGuest(
      setError: setError,
      setLoad: setLoad ?? isLoad,
    );
  }
}

class AuthStateRegisterSSO extends AuthState {
  final String email;
  final String idToken;
  final List<String> errorMessages;
  const AuthStateRegisterSSO({
    required this.email,
    required this.idToken,
    required bool setLoad,
    AuthError? setError,
    this.errorMessages = const [],
    bool setIsFirstEntry = false,
  }) : super(
          isLoad: setLoad,
          status: AuthStatus.ssoRegister,
          isFirstEntry: setIsFirstEntry,
          error: setError,
        );
  AuthStateRegisterSSO changeValue(
      {AuthError? setError,
      bool? setLoad,
      required String setIdToken,
      required String setEmail}) {
    return AuthStateRegisterSSO(
      email: setEmail,
      idToken: setIdToken,
      setError: setError,
      setLoad: setLoad ?? isLoad,
    );
  }

  @override
  List<Object?> get props => super.props + [email, idToken, errorMessages];
}
// class
