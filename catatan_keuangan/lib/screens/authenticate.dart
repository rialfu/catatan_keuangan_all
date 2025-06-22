import 'dart:async';
import 'package:catatan_keuangan/components/forgot_password_component.dart';
import 'package:catatan_keuangan/components/login_component.dart';
import 'package:catatan_keuangan/components/register_component.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/screens/notifier/authenticate_screen_notifier.dart';
import 'package:provider/provider.dart';

import '../extensions/context_entension.dart';
import 'package:flutter/material.dart';

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({super.key});

  @override
  State<AuthenticateScreen> createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // final _signUpGlobalKey = GlobalKey<FormState>();

  bool hidePass = true;
  bool formSignIn = true;
  bool formSignUp = false;
  late final AuthBloc authBloc;
  late StreamSubscription authStream;
  // AuthenticateScreenNotifier? notifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authBloc = context.read<AuthBloc>();
    // notifier = context.read<AuthenticateScreenNotifier>();

    authStream = authBloc.stream.listen((state) {
      /// statements after async gap without warning
      if (state is AuthStateLogin) {
        // if (state is LoginState) {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => state.status.firstView),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    // notifier?.dispose();
    emailController.dispose();
    passwordController.dispose();
    authStream.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double heightScreen = context.dynamicHeight(1);
    double widthScreen = context.dynamicWidth(1);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ChangeNotifierProvider(
        create: (context) => AuthenticateScreenNotifier(
          // context.dynamicWidth(1),
          // context.dynamicHeight(1),
          widthScreen, heightScreen,
        ),
        child: Container(
          height: context.dynamicHeight(1),
          width: context.dynamicWidth(1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.red.shade800, Colors.black54],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            children: [
              Consumer<AuthenticateScreenNotifier>(builder: (
                context,
                value,
                child,
              ) {
                return AnimatedOpacity(
                  opacity: value.firstTime ? 1 : 0,
                  // opacity: value.page == 'first' ? 1 : 0,
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  child: SizedBox(
                    // color: Colors.yellow,
                    height: context.dynamicHeight(1),
                    width: context.dynamicWidth(1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                              // color: Colors.blue,
                              ),
                        ),
                        Expanded(
                          flex: 1,
                          // child: FittedBox(
                          //   fit: BoxFit.fill,
                          child: Container(
                            // color: Colors.amber,
                            child: Image.network(
                              'https://www.freepnglogos.com/uploads/logo-3d-png/3d-company-logos-design-logo-online-2.png',
                              height: context.dynamicWidth(0.3),
                              width: context.dynamicWidth(0.3),
                              errorBuilder: (context, error, stackTrace) =>
                                  new Icon(Icons.error),
                              // width: 40,
                            ),
                          ),
                          // ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            // color: Colors.deepOrange,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: context.dynamicHeight(0.07),
                                ),
                                Text(
                                  "Welcome Back ",
                                  style: TextStyle(
                                    fontSize: context.dynamicHeight(0.03),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  width: context.dynamicWidth(0.7),
                                  height: context.dynamicHeight(0.065),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<AuthenticateScreenNotifier>()
                                          // .changePage('register');
                                          .changeToBody('register');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      side: const BorderSide(
                                        width: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: context.dynamicHeight(0.02),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                SizedBox(
                                  width: context.dynamicWidth(0.7),
                                  height: context.dynamicHeight(0.065),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<AuthenticateScreenNotifier>()
                                          // .changePage('login');
                                          .changeToBody('login');
                                      // setState(() {
                                      //   // page = 'login';
                                      // });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      // foregroundColor: Colors.black,
                                      elevation: 0,
                                      side: const BorderSide(
                                        width: 1.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: context.dynamicHeight(0.02),
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
              // Consumer<AuthenticateScreenNotifier>(
              //   builder: (context, value, child) {
              //     return AnimatedPositioned(
              //       top: context.dynamicHeight(0.1),
              //       duration: Duration(milliseconds: 300),
              //       left: value.page == 'first'
              //           ? -context.dynamicHeight(0.2)
              //           : context.dynamicWidth(0.1),
              //       child: Text(
              //         value.page == 'login'
              //             ? "Hello \nSign In!"
              //             : "Create Your \nAccount ",
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: context.dynamicHeight(0.035),
              //           fontWeight: FontWeight.w800,
              //         ),
              //       ),
              //     );
              //   },
              // ),
              Consumer<AuthenticateScreenNotifier>(
                builder: (context, value, child) {
                  return AnimatedPositioned(
                    top: context.dynamicHeight(0.1),
                    duration: Duration(milliseconds: 300),
                    left: value.titleScreenLogin,
                    child: Text(
                      "Hello \nSign In!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.035),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              Consumer<AuthenticateScreenNotifier>(
                builder: (context, value, child) {
                  return AnimatedPositioned(
                    top: context.dynamicHeight(0.1),
                    duration: Duration(milliseconds: 300),
                    left: value.titleScreenForgotPass,
                    child: Text(
                      "Forgot \nPassword Here!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.035),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              Consumer<AuthenticateScreenNotifier>(
                builder: (context, value, child) {
                  return AnimatedPositioned(
                    top: context.dynamicHeight(0.1),
                    duration: Duration(milliseconds: 300),
                    left: value.titleScreenRegister,
                    child: Text(
                      "Create Your \nAccount ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicHeight(0.035),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                child: Consumer<AuthenticateScreenNotifier>(builder: (
                  context,
                  value,
                  child,
                ) {
                  return AnimatedContainer(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    duration: Duration(milliseconds: 300),
                    height: value.heightBody,
                    width: context.dynamicWidth(1),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          // top: value.bottomLogin,
                          left: value.leftLogin,
                          // left: 1,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            height: context.dynamicHeight(0.65),
                            width: context.dynamicWidth(1),
                            padding: EdgeInsets.only(
                              right: context.dynamicWidth(0.1),
                              left: context.dynamicWidth(0.1),
                            ),
                            child: LoginComponent(),
                          ),
                        ),
                        AnimatedPositioned(
                          // top: value.bottomLogin,
                          left: value.leftResetPass,
                          // left: 1,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            height: context.dynamicHeight(0.65),
                            width: context.dynamicWidth(1),
                            padding: EdgeInsets.only(
                              right: context.dynamicWidth(0.1),
                              left: context.dynamicWidth(0.1),
                            ),
                            child: ForgotPasswordComponent(),
                          ),
                        ),
                        AnimatedPositioned(
                          // top: value.bottomRegister,
                          left: value.leftRegister,
                          // left: 1,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            padding: EdgeInsets.only(
                              right: context.dynamicWidth(0.1),
                              left: context.dynamicWidth(0.1),
                            ),
                            height: context.dynamicHeight(0.65),
                            width: context.dynamicWidth(1),
                            child: RegisterComponent(),
                          ),
                        ),
                        AnimatedPositioned(
                          bottom: value.bottomLogin,
                          duration: Duration(milliseconds: 300),
                          right: value.rightLogin,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: context.dynamicWidth(0.1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Don't have account?",
                                  style: TextStyle(
                                    fontSize: context.dynamicHeight(0.015),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    context
                                        .read<AuthenticateScreenNotifier>()
                                        .closeLogin();
                                    await Future.delayed(
                                        Duration(milliseconds: 150));
                                    context
                                        .read<AuthenticateScreenNotifier>()
                                        // .changePage('register');
                                        .openRegister();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: context.dynamicHeight(0.02),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          bottom: value.bottomRegister,
                          duration: Duration(milliseconds: 200),
                          right: value.rightRegister,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: context.dynamicWidth(0.1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Do have account?",
                                  style: TextStyle(
                                    fontSize: context.dynamicHeight(0.015),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    context
                                        .read<AuthenticateScreenNotifier>()
                                        // .changePage('register');
                                        .closeRegister();
                                    await Future.delayed(
                                        Duration(milliseconds: 200));
                                    context
                                        .read<AuthenticateScreenNotifier>()
                                        // .changePage('register');
                                        .openLogin();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: context.dynamicHeight(0.02),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    // child: value.page == 'login'
                    //     ? LoginScreen()
                    //     : RegisterScreen(),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
