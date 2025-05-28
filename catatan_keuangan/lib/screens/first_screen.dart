// import 'package:catatan_app/components/button.dart';
import 'dart:async';

// import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/screens/notifier/first_screen_notifier.dart';
import 'package:catatan_keuangan/template/loginscreen.dart';
import 'package:catatan_keuangan/template/registerscreen.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../extensions/context_entension.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  // final _signUpGlobalKey = GlobalKey<FormState>();

  bool hidePass = true;
  bool formSignIn = true;
  bool formSignUp = false;
  late final AuthBloc authBloc;
  late StreamSubscription authStream;
  // String page = 'first';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authBloc = context.read<AuthBloc>();

    authStream = authBloc.stream.listen((state) {
      /// statements after async gap without warning
      if (state is AuthStateLogin) {
        print('masuk sini');
        // if (state is LoginState) {
        Future.delayed(Duration(seconds: 2), () {
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
    emailController.dispose();
    passwordController.dispose();
    authStream.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ChangeNotifierProvider(
        create: (context) => FirstScreenNotifier(),
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
              Consumer<FirstScreenNotifier>(builder: (
                context,
                value,
                child,
              ) {
                return AnimatedOpacity(
                  opacity: value.page == 'first' ? 1 : 0,
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
                                          .read<FirstScreenNotifier>()
                                          .changePage('register');
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
                                          .read<FirstScreenNotifier>()
                                          .changePage('login');
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
              Consumer<FirstScreenNotifier>(builder: (
                context,
                value,
                child,
              ) {
                return AnimatedPositioned(
                  top: context.dynamicHeight(0.1),
                  duration: Duration(milliseconds: 300),
                  left: value.page == 'first'
                      ? -context.dynamicHeight(0.2)
                      : context.dynamicWidth(0.1),
                  child: Text(
                    value.page == 'login'
                        ? "Hello \nSign In!"
                        : "Create Your \nAccount ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicHeight(0.035),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }),
              Positioned(
                bottom: 0,
                child: Consumer<FirstScreenNotifier>(builder: (
                  context,
                  value,
                  child,
                ) {
                  return AnimatedContainer(
                    padding: EdgeInsets.only(
                      right: context.dynamicWidth(0.1),
                      left: context.dynamicWidth(0.1),
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
                    height:
                        value.page == 'first' ? 0 : context.dynamicHeight(0.65),
                    width: context.dynamicWidth(1),
                    // child: AnimatedOpacity(
                    //   duration: Duration(milliseconds: 500),
                    //   opacity: value.page == 'login' ? 1 : 0,
                    //   child: Loginscreen(),
                    // ),
                    child: value.page == 'login'
                        ? LoginScreen()
                        : RegisterScreen(),
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
