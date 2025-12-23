// import 'dart:io';

import 'package:catatan_keuangan/core/model/auth_model.dart';
import 'package:catatan_keuangan/core/model/login_sso_model.dart';
import 'package:catatan_keuangan/core/service/auth_service.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../enum/auth_enum.dart';
// import '../../service/auth_service.dart';
// import '../../service/interface_auth_service.dart';
import '../../../init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final IAuthService authService;
  final AuthService authService;
  final AuthCacheManager authCacheManager;

  AuthBloc(this.authService, this.authCacheManager)
      : super(AuthState()
            // const AuthState.unknown()

            ) {
    on<AppStarted>((event, emit) async {
      bool isFirstEntry = await authCacheManager.isFirstEntry();
      try {
        emit(AuthState(
          status: AuthStatus.unknown,
          isLoad: true,
          isFirstEntry: true,
        ));

        if (await authCacheManager.isLoggedIn()) {
          // print('masuk sini 1');
          await authCacheManager.updateTokenFromStorage();
          String? res = await authService.getStatus();
          // print('res:$res');
          if (res == null) {
            await authCacheManager.signOut();
            emit(AuthStateGuest(setLoad: false));
            // emit(const AuthState.guest());
            return;
          }
          String? email = await authCacheManager.getEmail();
          emit(AuthStateLogin(
            setName: res,
            setEmail: email ?? '',
            setLoad: false,
          ));
          return;
          // emit(LoginState(newName: res));
          // emit(AuthState.authenticated(newName: res));
        } else {
          // print('masuk sini 2');
          if (await authCacheManager.isFirstEntry()) {
            emit(AuthStateGuest(
              setLoad: false,
              setIsFirstEntry: true,
            ));
          } else {
            emit(AuthStateGuest(
              setLoad: false,
              setIsFirstEntry: false,
            ));
          }
          // emit((await authCacheManager.isFirstEntry())
          //     ? const AuthState.firstEntry()
          //     : const AuthState.guest());
        }
      } catch (e) {
        emit(AuthStateGuest(
          setLoad: false,
          setIsFirstEntry: isFirstEntry,
        ));
        // emit(const AuthState.error());
      }
    });

    on<LoginRequested>(
      (event, emit) async {
        try {
          emit(AuthStateGuest(
            setLoad: true,
            setIsFirstEntry: false,
          ));
          // emit(const AuthState.load());
          final AuthModel? result = await authService.login(
              email: event.email, password: event.password);

          if (result != null && result.token != null) {
            await authCacheManager.updateToken(
              result.token,
              refreshToken: result.refreshToken,
            );
            String? res = await authService.getStatus();
            if (res == null) {
              await authCacheManager.signOut();
              emit(AuthStateGuest(
                setLoad: false,
                setError: AuthError.wrongEmailOrPassword,
                setIsFirstEntry: false,
              ));
              return;
            }
            await authCacheManager.updateLoggedIn(true);
            Map<String, dynamic>? authSaved = await authCacheManager.getAuth();
            if (authSaved != null) {
              if (!authSaved.containsKey('email')) {
                authCacheManager.clearAuth();
              } else if (authSaved['email'] != event.email) {
                authCacheManager.clearAuth();
              }
            }
            // authCacheManager.setEmail(event.email);
            emit(AuthStateLogin(
              setEmail: event.email,
              setLoad: false,
              setName: res,
            ));
            // emit(LoginState(newName: result.name));
          } else {
            // add(LogoutRequested());
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.wrongEmailOrPassword,
              setIsFirstEntry: false,
            ));
            // emit(const AuthState.error(error: AuthError.wrongEmailOrPassword));
          }
        } on CustomExceptionForPost catch (err) {
          if (err.codeError == 0) {
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.hostUnreachable,
              setIsFirstEntry: false,
            ));

            // emit(const AuthState.error(error: AuthError.hostUnreachable));
          } else {
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.wrongEmailOrPassword,
              setIsFirstEntry: false,
            ));
          }
          await authCacheManager.signOut();
        } catch (err) {
          // print('error:${err.toString()}');
          emit(AuthStateGuest(
            setLoad: false,
            setError: AuthError.unknown,
            setIsFirstEntry: false,
          ));
          await authCacheManager.signOut();
          // emit(const AuthState.error(error: AuthError.wrongEmailOrPassword));
        }
      },
    );
    on<LoginRequestedWithBiometric>(
      (event, emit) async {
        try {
          emit(AuthStateGuest(
            setLoad: true,
            setIsFirstEntry: false,
          ));
          // emit(const AuthState.load());
          final AuthModel? result = await authService.login(
              email: event.email, password: event.password);

          if (result != null && result.token != null) {
            await authCacheManager.updateToken(
              result.token,
              refreshToken: result.refreshToken,
            );
            String? res = await authService.getStatus();
            if (res == null) {
              await authCacheManager.signOut();
              emit(AuthStateGuest(
                setLoad: false,
                setError: AuthError.wrongEmailOrPasswordBiometric,
                setIsFirstEntry: false,
              ));
              return;
            }
            await authCacheManager.updateLoggedIn(true);
            emit(AuthStateLogin(
              setEmail: event.email,
              setLoad: false,
              setName: res,
            ));
          } else {
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.wrongEmailOrPasswordBiometric,
              setIsFirstEntry: false,
            ));
          }
        } on CustomExceptionForPost catch (err) {
          if (err.codeError == 0) {
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.hostUnreachable,
              setIsFirstEntry: false,
            ));
            // emit(const AuthState.error(error: AuthError.hostUnreachable));
          } else {
            authCacheManager.clearAuth();
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.wrongEmailOrPasswordBiometric,
              setIsFirstEntry: false,
            ));
          }
          await authCacheManager.signOut();
        } catch (err) {
          // print('error:${err.toString()}');
          emit(AuthStateGuest(
            setLoad: false,
            setError: AuthError.unknown,
            setIsFirstEntry: false,
          ));
          await authCacheManager.signOut();
          // emit(const AuthState.error(error: AuthError.wrongEmailOrPassword));
        }
      },
    );

    on<LogoutRequested>((event, emit) async {
      try {
        await authCacheManager.signOut();
        emit(AuthStateGuest(
          setLoad: false,
          setIsFirstEntry: false,
        ));
      } catch (_) {}
    });
    on<CleanAuthRequest>(
      (event, emit) {
        emit(AuthStateGuest(
          setLoad: false,
          setIsFirstEntry: false,
        ));
        // emit(AuthState.guest());
      },
    );
    on<CleanAuthRequestRegister>(
      (event, emit) {
        emit(AuthStateRegisterSSO(
          setLoad: false,
          email: event.email,
          idToken: event.idToken,
        ));
        // emit(AuthState.guest());
      },
    );
    on<LoginWithGoogleSSO>(
      (event, emit) async {
        try {
          emit(AuthStateGuest(
            setLoad: true,
            setIsFirstEntry: false,
          ));
          String token = event.idToken;
          var inp = LoginSSOModel(
            idToken: token,
            name: null,
            password: null,
          );
          final result = await authService.signInSSO(inp);
          if (result.containsKey('register') && result['register'] == true) {
            emit(AuthStateRegisterSSO(
              setLoad: false,
              email: event.email,
              idToken: token,
              setIsFirstEntry: false,
            ));
            return;
          }

          if (result.containsKey('access_token')) {
            final modelData = AuthModel.fromJson(result);

            await authCacheManager.updateToken(
              modelData.token,
              refreshToken: modelData.refreshToken,
            );

            String? res = await authService.getStatus();
            if (res == null) {
              await authCacheManager.signOut();
              emit(AuthStateGuest(
                setLoad: false,
                setError: AuthError.unknown,
                setIsFirstEntry: false,
              ));
              return;
            }
            await authCacheManager.updateLoggedIn(true);
            emit(AuthStateLogin(
              setEmail: event.email,
              setLoad: false,
              setName: res,
            ));
            return;
          }
          emit(AuthStateGuest(
            setLoad: false,
            setError: AuthError.unknown,
            setIsFirstEntry: false,
          ));
        } on CustomExceptionForPost catch (err) {
          if (err.codeError == 0) {
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.hostUnreachable,
              setIsFirstEntry: false,
            ));
            // emit(const AuthState.error(error: AuthError.hostUnreachable));
          } else {
            authCacheManager.clearAuth();
            emit(AuthStateGuest(
              setLoad: false,
              setError: AuthError.failedGoogleSSO,
              setIsFirstEntry: false,
            ));
          }
          await authCacheManager.signOut();
        } catch (err) {
          // print("masuk e")
          print('error:${err.toString()}');
          emit(AuthStateGuest(
            setLoad: false,
            setError: AuthError.unknown,
            setIsFirstEntry: false,
          ));
          await authCacheManager.signOut();
        }
      },
    );
    on<RegisterWithGoogleSSO>(
      (event, emit) async {
        try {
          print("start bloc register google sso");
          emit(AuthStateRegisterSSO(
            idToken: event.idToken,
            email: event.email,
            setLoad: true,
          ));
          var inp = LoginSSOModel(
            idToken: event.idToken,
            name: event.name,
            password: event.password,
          );
          final result = await authService.registerSSO(inp);

          if (result != null && result.token != null) {
            await authCacheManager.updateToken(
              result.token,
              refreshToken: result.refreshToken,
            );
            String? res = await authService.getStatus();
            if (res == null) {
              await authCacheManager.signOut();
              emit(AuthStateRegisterSSO(
                setLoad: false,
                setError: AuthError.failedGoogleSSO,
                email: event.email,
                idToken: event.idToken,
                setIsFirstEntry: false,
                errorMessages: ["Gagal mendapatkan profile"],
              ));
              return;
            }
            await authCacheManager.updateLoggedIn(true);
            emit(AuthStateLogin(
              setEmail: event.email,
              setLoad: false,
              setName: res,
            ));
          } else {
            emit(AuthStateRegisterSSO(
              idToken: event.idToken,
              email: event.email,
              setLoad: false,
              setError: AuthError.failedGoogleSSO,
              errorMessages: ["Gagal mendapatkan autentikasi"],
            ));
          }
        } on CustomExceptionForPost catch (err) {
          if (err.codeError == 0) {
            emit(AuthStateRegisterSSO(
              email: event.email,
              setLoad: false,
              setError: AuthError.hostUnreachable,
              setIsFirstEntry: false,
              idToken: event.idToken,
            ));
            // emit(const AuthState.error(error: AuthError.hostUnreachable));
          } else {
            authCacheManager.clearAuth();
            List<String> messages =
                err.cause is List ? err.cause : [err.cause.toString()];

            emit(AuthStateRegisterSSO(
              email: event.email,
              setLoad: false,
              setError: AuthError.failedGoogleSSO,
              errorMessages: messages,
              setIsFirstEntry: false,
              idToken: event.idToken,
            ));
          }
          await authCacheManager.signOut();
        } catch (err) {
          // print('error:${err.toString()}');
          emit(AuthStateRegisterSSO(
            email: event.email,
            setLoad: false,
            setError: AuthError.unknown,
            setIsFirstEntry: false,
            idToken: event.idToken,
          ));
          await authCacheManager.signOut();
        }
      },
    );
  }
}
