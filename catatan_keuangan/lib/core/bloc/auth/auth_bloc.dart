// import 'dart:io';

import 'package:catatan_keuangan/core/model/auth_model.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../enum/auth_enum.dart';
// import '../../service/auth_service.dart';
import '../../service/interface_auth_service.dart';
import '../../../init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService authService;
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
    // on<RegisterRequested>(
    //   (event, emit) async {
    //     try {
    //       emit(AuthLoading());
    //       await (authService as AuthService).register(event.data);
    //       emit(AuthState.guest());
    //     } on CustomExceptionForPost catch (e) {
    //       if (e.codeError == 400) {
    //         emit(AuthState.error(error: ))
    //         // print(stateStatus.message);
    //       }
    //     } catch(err){

    //     }

    //   },
    // );
    //
  }
}
