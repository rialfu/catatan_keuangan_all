import 'package:flutter/material.dart';

class AuthenticateScreenNotifier extends ChangeNotifier {
  String page = 'first';

  bool firstTime = true;
  double _widthScreen = 0;
  double _heightScreen = 0;
  double titleScreenLogin = 0;
  double titleScreenRegister = 0;
  double titleScreenForgotPass = 0;
  double heightBody = 0;
  double leftRegister = 0;
  double leftLogin = 0;
  double rightLogin = 0;
  double rightRegister = 0;
  double bottomLogin = 0;
  double bottomRegister = 0;
  double leftResetPass = 0;
  // factory
  AuthenticateScreenNotifier(double widthScreen, double heightScreen) {
    _widthScreen = widthScreen;
    _heightScreen = heightScreen;
    titleScreenLogin = -1 * widthScreen * 0.45;
    titleScreenRegister = -1 * widthScreen * 0.45;
    titleScreenForgotPass = -1 * widthScreen * 0.55;
    // rightRegister = _widthScreen * -1;
    leftLogin = _widthScreen * -1;
    leftRegister = _widthScreen * -1;
    bottomLogin = heightScreen * 0.65 * -1;
    bottomRegister = heightScreen * 0.65 * -1;
    leftResetPass = _widthScreen * -1;
    notifyListeners();
  }
  void changePage(String page) {
    this.page = page;
    notifyListeners();
  }

  void changeToBody(String page) {
    if (page == 'login') {
      titleScreenLogin = _widthScreen * 0.1;
      this.page = 'login';
      leftRegister = _widthScreen * -1;
      leftLogin = 0;
      rightRegister = _widthScreen * -1 * 0.5;
    } else {
      this.page = 'register';
      titleScreenRegister = _widthScreen * 0.1;
      leftLogin = _widthScreen * -1;
      leftRegister = 0;
      rightLogin = _widthScreen * -1 * 0.5;
    }
    bottomLogin = 0;
    bottomRegister = 0;
    heightBody = _heightScreen * 0.65;
    firstTime = false;

    notifyListeners();
  }

  void closeRegister() {
    leftRegister = _widthScreen * -1;
    rightRegister = _widthScreen * -1 * 0.4;
    titleScreenRegister = -1 * _widthScreen * 0.45;
    notifyListeners();
  }

  void openRegister() {
    page = 'register';
    leftRegister = 0;
    rightRegister = 0;
    titleScreenRegister = _widthScreen * 0.1;
    notifyListeners();
  }

  void openLogin() {
    page = 'login';
    leftLogin = 0;
    rightLogin = 0;
    titleScreenLogin = _widthScreen * 0.1;
    notifyListeners();
  }

  void closeLogin() {
    leftLogin = _widthScreen * -1;
    rightLogin = _widthScreen * -1 * 0.4;
    titleScreenLogin = -1 * _widthScreen * 0.45;
    notifyListeners();
  }

  void openResetPass() {
    page = 'reset';
    leftResetPass = 0;
    titleScreenForgotPass = _widthScreen * 0.1;
    notifyListeners();
  }

  void closeResetPass() {
    leftResetPass = _widthScreen * -1;
    titleScreenForgotPass = -1 * _widthScreen * 0.55;
    notifyListeners();
  }
}
