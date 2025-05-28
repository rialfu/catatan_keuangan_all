import 'package:catatan_keuangan/screens/main_screen.dart';

import '../../core/enum/auth_enum.dart';
import '../../screens/first_screen.dart';
import 'package:flutter/material.dart';

extension NavigateExtension on AuthStatus {
  Widget get firstView {
    switch (this) {
      case AuthStatus.authenticated:
        return MainScreen();
      // return const HomeView();
      case AuthStatus.guest:
        // return const LoginView();
        return FirstScreen();
      case AuthStatus.unknown:
        // return SplashView();
        break;
      // return FirstScreen();
    }
    return FirstScreen();
    // return const LoginView();
  }
}
