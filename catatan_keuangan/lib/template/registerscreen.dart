import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:catatan_keuangan/screens/notifier/first_screen_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../extensions/context_entension.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _signInGlobalKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool hidePass = true;
  // String pattern = r'[a-z0-9A-Z\.]+@[a-zA-Z]+\.(com|co.id|go.id)';
  String pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

  Future<void> register(BuildContext contextD) async {
    print('da');
    // var dio = Dio();
    try {
      await DioManager.instance.dio.post('create-account', data: {
        'email': emailController.text,
        'name': nameController.text,
        'password': passwordController.text
      });
      if (contextD.mounted) {
        showMessage(contextD, ['Success add new data'], 'Success Info');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 429) {
        Map responseMessage = e.response?.data as Map;
        if (responseMessage.containsKey('message')) {
          List message = [];
          if (responseMessage['message'] is List) {
            message = responseMessage['message'];
          } else if (responseMessage['message'] is String) {
            message.add(responseMessage['message']);
          }
          if (contextD.mounted) {
            showMessage(contextD, message, 'error');
          }
        }
      }
    } catch (err) {
      print('error');
      print(err);
    }
  }

  void showMessage(BuildContext contextD, List message, String title) {
    showDialog(
      context: contextD,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: message.map((e) => Text(e.toString())).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();

                // authBloc.add(LogoutRequested());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    confPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
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
                onPressed: () {
                  context.read<FirstScreenNotifier>().changePage('login');
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
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Form(
              key: _signInGlobalKey,
              child: Column(
                children: [
                  SizedBox(
                    height: context.dynamicHeight(0.02),
                  ),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5, bottom: 8),
                      label: Text(
                        "Name",
                        style: TextStyle(fontSize: 20),
                      ),
                      suffixIcon: Icon(Icons.people),
                    ),
                  ),
                  SizedBox(
                    height: context.dynamicHeight(0.007),
                  ),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      // return 'ddd';
                      var formatRegex = RegExp(pattern);
                      if (value == null || value.isEmpty) {
                        return 'Please fill email';
                      }

                      if (!formatRegex.hasMatch(value)) {
                        return 'Please fill valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5, bottom: 8),
                      label: Text(
                        "Email",
                        style: TextStyle(
                            fontSize: context.fontSizeBasedScreen(0.8)),
                      ),
                      suffixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(
                    height: context.dynamicHeight(0.007),
                  ),
                  TextFormField(
                    controller: passwordController,
                    obscureText: hidePass,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5, bottom: 8),
                      label: Text(
                        "Password",
                        style: TextStyle(
                            fontSize: context.fontSizeBasedScreen(0.8)),
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
                    height: context.dynamicHeight(0.01),
                  ),
                  TextFormField(
                    controller: confPasswordController,
                    obscureText: hidePass,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value != passwordController.text) {
                        return 'Confirmation password is not same';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 5, bottom: 8),
                      label: Text(
                        "Confirmation Password",
                        style: TextStyle(
                            fontSize: context.fontSizeBasedScreen(0.8)),
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
                    height: context.dynamicHeight(0.03),
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
                        if (_signInGlobalKey.currentState?.validate() ??
                            false) {
                          register(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        "SIGN UP",
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
        ),
      ],
    );
  }
}
