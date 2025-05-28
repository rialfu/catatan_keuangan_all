import 'dart:async';

import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/screens/notifier/first_screen_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../extensions/context_entension.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _signInGlobalKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');
  bool hidePass = true;
  late StreamSubscription stream;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var bloc = context.read<AuthBloc>();
    stream = bloc.stream.listen(listening);
  }

  Future<void> listening(state) async {
    String titleMessage = "Error";
    String message = "App couldnt connect to server";
    if (state.error == AuthError.hostUnreachable) {
    } else if (state.error == AuthError.wrongEmailOrPassword) {
      message = "Username or Password is wrong";
    } else if (state.error == AuthError.unknown) {
      message = "App crash, please reinstall or call developer";
    }
    if (state.error == AuthError.wrongEmailOrPassword ||
        state.error == AuthError.hostUnreachable) {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleMessage),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(message)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  var bloc = context.read<AuthBloc>();
                  bloc.add(CleanAuthRequest());
                  Navigator.of(context).pop();

                  // authBloc.add(LogoutRequested());
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        // stream: null,
        builder: (context, stateBloc) {
      return Stack(
        children: [
          SingleChildScrollView(
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
                    controller: emailController,
                    decoration: InputDecoration(
                        label: Text(
                          "Email",
                          style: TextStyle(fontSize: 20),
                        ),
                        suffixIcon: Icon(Icons.email_outlined)),
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
                    height: context.dynamicHeight(0.05),
                  ),
                  Container(
                    width: context.dynamicWidth(1),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (stateBloc.isLoad) return;
                        if (_signInGlobalKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                LoginRequested(
                                  emailController.text,
                                  passwordController.text,
                                ),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: stateBloc.isLoad
                          ? CircularProgressIndicator()
                          : Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.dynamicHeight(0.02),
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Dont have account?",
                  style: TextStyle(
                    fontSize: context.dynamicHeight(0.015),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<FirstScreenNotifier>().changePage('register');
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
          )
        ],
      );
    });
  }
}
