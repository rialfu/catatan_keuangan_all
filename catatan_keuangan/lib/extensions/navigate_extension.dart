import 'package:catatan_keuangan/screens/RegisterSSOScreen.dart';
import 'package:catatan_keuangan/screens/authenticate.dart';
import 'package:catatan_keuangan/screens/main_screen.dart';

import '../../core/enum/auth_enum.dart';
// import '../../screens/first_screen.dart';
import 'package:flutter/material.dart';

extension NavigateExtension on AuthStatus {
  Widget get firstView {
    switch (this) {
      case AuthStatus.authenticated:
        return MainScreen();
      case AuthStatus.guest:
        return AuthenticateScreen();
      case AuthStatus.ssoRegister:
        return Registerssoscreen();

      case AuthStatus.unknown:
        break;
    }
    return AuthenticateScreen();
    // return FirstScreen();
    // return const LoginView();
  }
}
