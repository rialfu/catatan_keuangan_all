import 'dart:io';

import 'package:catatan_keuangan/core/model/auth_model.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../enum/auth_enum.dart';
import '../../service/auth_service.dart';
import '../../service/interface_auth_service.dart';
import '../../../init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthService authService;
  final AuthCacheManager authCacheManager;

  AuthBloc(this.authService, this.authCacheManager)
      : super(const AuthState.unknown()) {
    on<AppStarted>((event, emit) async {
      try {
        if (await authCacheManager.isLoggedIn()) {
          print('masuk sini 1');
          await authCacheManager.updateTokenFromStorage();
          String? res = await (authService as AuthService).getStatus();
          print('res:$res');
          if (res == null) {
            await authCacheManager.signOut();
            emit(const AuthState.guest());
            return;
          }
          emit(LoginState(newName: res));
          // emit(AuthState.authenticated(newName: res));
        } else {
          print('masuk sini 2');
          emit((await authCacheManager.isFirstEntry())
              ? const AuthState.firstEntry()
              : const AuthState.guest());
        }
      } on SocketException catch (err) {
        print(err);
        emit(const AuthState.error(error: AuthError.hostUnreachable));
      } catch (e) {
        print(e);
        emit(const AuthState.error());
      }
    });

    on<LoginRequested>(
      (event, emit) async {
        try {
          final AuthModel? result = await authService.login(
              email: event.email, password: event.password);
          // print(result);
          // print(result?.token ?? 'tidak ada');
          if (result != null && result.token != null) {
            await authCacheManager.updateToken(
              result.token,
              refreshToken: result.refreshToken,
            );
            await authCacheManager.updateLoggedIn(true);

            emit(LoginState(newName: result.name));
          } else {
            // add(LogoutRequested());
            emit(const AuthState.error(error: AuthError.wrongEmailOrPassword));
          }
        } catch (err) {
          print('error:${err.toString()}');
          emit(const AuthState.error(error: AuthError.wrongEmailOrPassword));
        }
      },
    );

    on<LogoutRequested>((event, emit) async {
      try {
        await authCacheManager.signOut();
        emit(const AuthState.guest());
      } catch (_) {}
    });
    on<CleanAuthRequest>(
      (event, emit) {
        emit(AuthState.guest());
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
