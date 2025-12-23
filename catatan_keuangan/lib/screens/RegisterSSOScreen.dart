import 'dart:async';

import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Registerssoscreen extends StatefulWidget {
  const Registerssoscreen({super.key});

  @override
  State<Registerssoscreen> createState() => _RegisterssoscreenState();
}

class _RegisterssoscreenState extends State<Registerssoscreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final _signInGlobalKey = GlobalKey<FormState>();

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

    // authBloc.state
    if (authBloc.state is AuthStateRegisterSSO) {
      emailController.text = authBloc.state.email;
    }

    authStream = authBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is AuthStateRegisterSSO) {
        String titleMessage = "Error";
        List<String> message = [MessageCustom.serverNotActive];
        // String message = "App couldnt connect to server";
        if (state.error == AuthError.unknown) {
          message = ["App something wrong, please reinstall or call developer"];
        } else if (state.error == AuthError.failedGoogleSSO) {
          message = [
            "Something is wrong with System or Google",
            "Please Try again or use standart login"
          ];
          if (state.errorMessages.isNotEmpty) {
            message = state.errorMessages;
          }
        }
        if (state.error == AuthError.unknown ||
            state.error == AuthError.hostUnreachable ||
            state.error == AuthError.failedGoogleSSO) {
          ComponentCustom.alert(
            context,
            message,
            titleMessage,
            callback: () {
              var bloc = context.read<AuthBloc>();
              bloc.add(CleanAuthRequestRegister(state.idToken, state.email));
              Navigator.of(context).pop();
            },
          );
        }
      }
      if (state is AuthStateLogin || state is AuthStateGuest) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (!mounted) return;
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
    nameController.dispose();
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
      body: Container(
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
            Positioned(
              top: context.dynamicHeight(0.1),
              // duration: Duration(milliseconds: 300),
              left: 50,
              child: Text(
                "Please Complete \nRegister ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicHeight(0.035),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
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
                height: heightScreen * 0.65,
                width: context.dynamicWidth(1),
                child: Form(
                  key: _signInGlobalKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: context.dynamicHeight(0.05),
                      ),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please input';
                          }

                          return val.isValidEmail()
                              ? null
                              : 'Please input format email';
                        },
                        readOnly: true,
                        controller: emailController,
                        decoration: InputDecoration(
                          label: Text(
                            "Email",
                            style: TextStyle(fontSize: 20),
                          ),
                          suffixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please input';
                          }
                          if (val.length > 50) {
                            return "Maksimal 50 karakter";
                          }
                        },
                        controller: nameController,
                        decoration: InputDecoration(
                          label: Text(
                            "Name",
                            style: TextStyle(fontSize: 20),
                          ),
                          suffixIcon: Icon(Icons.people),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: hidePass,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please input';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text(
                            "Password",
                            style: TextStyle(fontSize: 20),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                hidePass = !hidePass;
                              });
                            },
                            child: Icon(
                              hidePass
                                  ? Icons.visibility_off
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: context.dynamicHeight(0.02),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              // width: context.dynamicWidth(1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.red.shade800,
                                    Colors.black54
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                // borderRadius: BorderRadius.circular(20)
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(CleanAuthRequest());
                                  // print()
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  "Back",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.dynamicHeight(0.02),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 6,
                            child: Container(
                              // width: context.dynamicWidth(1),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.red.shade800,
                                    Colors.black54
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                // borderRadius: BorderRadius.circular(20)
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_signInGlobalKey.currentState!
                                      .validate()) {
                                    var bloc = context.read<AuthBloc>();
                                    var state = bloc.state;
                                    if (state is AuthStateRegisterSSO) {
                                      bloc.add(RegisterWithGoogleSSO(
                                        state.idToken,
                                        state.email,
                                        nameController.text,
                                        passwordController.text,
                                      ));
                                    }
                                  }

                                  // print()
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.dynamicHeight(0.02),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
