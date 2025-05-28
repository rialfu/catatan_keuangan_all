import '../../enum/auth_enum.dart';
import 'package:equatable/equatable.dart';

// class AuthState extends Equatable {
//   final AuthStatus status;
//   final bool isLoad;
//   final bool isFirstEntry;
//   final AuthError? error;
//   final String? name;

//   const AuthState({
//     this.status = AuthStatus.guest,
//     this.isFirstEntry = false,
//     this.error,
//     this.name,
//     this.isLoad = false,
//   });
//   const AuthState._({
//     this.status = AuthStatus.unknown,
//     this.isFirstEntry = true,
//     this.error,
//     this.name,
//     this.isLoad = false,
//   });
//   const AuthState.load()
//       : this._(
//           isLoad: true,
//           status: AuthStatus.guest,
//           isFirstEntry: false,
//         );
//   const AuthState.unknown() : this._();

//   const AuthState.authenticated({String? newName})
//       : this._(
//           status: AuthStatus.authenticated,
//           isFirstEntry: false,
//           name: newName,
//         );

//   const AuthState.guest()
//       : this._(
//           status: AuthStatus.guest,
//           isFirstEntry: false,
//         );

//   const AuthState.firstEntry() : this._(status: AuthStatus.guest);

//   const AuthState.error({AuthError error = AuthError.unknown})
//       : this._(status: AuthStatus.unknown, isFirstEntry: false, error: error);

//   AuthState updateName(String? newName) {
//     return AuthState._(
//       status: status,
//       isFirstEntry: isFirstEntry,
//       name: newName,
//     );
//   }

//   @override
//   List<Object?> get props => [status, isFirstEntry, error, name];
// }

// class LoginState extends AuthState {
//   // final AuthStatus status = AuthStatus.authenticated;
//   // final bool isFirstEntry = false;
//   // final AuthError? error;
//   // final String? name;
//   const LoginState({String? newName})
//       : super(
//           status: AuthStatus.authenticated,
//           isFirstEntry: false,
//           name: newName,
//         );
// }

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isLoad;
  final bool isFirstEntry;
  final AuthError? error;
  final String? name;
  final String dateNow;
  const AuthState({
    this.status = AuthStatus.guest,
    this.isLoad = false,
    this.isFirstEntry = false,
    this.name,
    this.error,
    this.dateNow = '',
  });
  @override
  List<Object?> get props => [
        status,
        isLoad,
        isFirstEntry,
        error,
        dateNow,
        name,
      ];
}

class AuthStateLogin extends AuthState {
  const AuthStateLogin({
    required String setDate,
    String? setName,
    required bool setLoad,
  }) : super(
          dateNow: setDate,
          name: setName,
          isLoad: setLoad,
          status: AuthStatus.authenticated,
          isFirstEntry: false,
        );
  AuthStateLogin changeValue({String? setDate, String? name, bool? isLoad}) {
    return AuthStateLogin(
      setDate: setDate ?? dateNow,
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
// class
