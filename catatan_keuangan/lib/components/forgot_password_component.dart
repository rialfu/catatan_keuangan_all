// ignore_for_file: use_build_context_synchronously

import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:catatan_keuangan/screens/notifier/authenticate_screen_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordComponent extends StatefulWidget {
  final AuthenticateScreenNotifier? notifier;
  const ForgotPasswordComponent({super.key, this.notifier});

  @override
  State<ForgotPasswordComponent> createState() =>
      _ForgotPasswordComponentState();
}

class _ForgotPasswordComponentState extends State<ForgotPasswordComponent> {
  TextEditingController emailController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool lockPass = true;
  bool isLoad = false;
  late AuthenticateScreenNotifier notifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifier = context.read<AuthenticateScreenNotifier>();
    notifier.addListener(listenNotifier);
    // widget.notifier?.addListener(listenNotifier);
  }

  @override
  void dispose() {
    notifier.removeListener(listenNotifier);
    // widget.notifier?.removeListener(listenNotifier);
    emailController.dispose();
    passController.dispose();
    codeController.dispose();
    super.dispose();
    // notifier.dispose();
  }

  void listenNotifier() {
    if (notifier.page == 'reset') {
      emailController.text = '';
      passController.text = '';
      codeController.text = '';
      setState(() {
        lockPass = true;
      });
    }
  }

  Future<void> processResetPass() async {
    if (codeController.text.isEmpty || passController.text.isEmpty) return;
    if (passController.text.length < 8) {
      ComponentCustom.alert(context, ['Password min 8 characters'], 'Info');
      return;
    }
    try {
      await DioManager.instance.dio.post(
        'auth/reset-password',
        data: {
          'email': emailController.text.trim(),
          'password': passController.text,
          'code': codeController.text.trim(),
        },
      );
      ComponentCustom.alert(context, ['Success update password'], 'Success');
    } on DioException catch (err) {
      List<String> message = CustomResponseError.buildResponseFromServer(err);
      // if (err.type == DioExceptionType.connectionTimeout) {
      //   ComponentCustom.alert(
      //     context,
      //     [MessageCustom.serverNotActive],
      //     'Error',
      //   );
      //   return;
      // }
      // List<String> message = ['Something is wrong here'];
      // if (err.response?.data is Map<String, dynamic>) {
      //   Map<String, dynamic> d = err.response!.data as Map<String, dynamic>;
      //   // print(err);
      //   if (d.containsKey('message')) {
      //     if (d['message'] is String) {
      //       message = [d['message']];
      //     } else if (d['message'] is List) {
      //       message = (d['message'] as List).map((e) => e.toString()).toList();
      //     }
      //   }
      //   // print(d);?
      // }
      ComponentCustom.alert(context, message, 'Error');
    } catch (err) {
      List<String> message = ['Something is wrong here'];
      ComponentCustom.alert(context, [message], 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spacer(),
                TextButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    context.read<AuthenticateScreenNotifier>().closeResetPass();
                    await Future.delayed(Duration(milliseconds: 300));
                    context.read<AuthenticateScreenNotifier>().openLogin();
                  },
                  child: Text('Back to login'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      try {
                        List<String> message = ['Code send your email'];
                        var res = await DioManager.instance.dio.post(
                            'auth/send-email',
                            data: {'email': emailController.text.trim()});
                        if (res.data is Map<String, dynamic>) {
                          Map<String, dynamic> d =
                              res.data as Map<String, dynamic>;
                          if (d.containsKey('message')) {
                            if (d['message'] is String) {
                              message = [d['message']];
                            } else if (d['message'] is List) {
                              message = d['message'];
                            }
                          }
                        }
                        ComponentCustom.alert(context, message, 'Info');
                        setState(() {
                          lockPass = false;
                        });
                      } on DioException catch (err) {
                        print(err);
                        if (err.type == DioExceptionType.connectionTimeout) {
                          ComponentCustom.alert(context,
                              [MessageCustom.serverNotActive], 'Message');
                        }
                        List<String> message = ['Something is wrong here'];
                        if (err.response?.data is Map<String, dynamic>) {
                          Map<String, dynamic> data =
                              err.response!.data as Map<String, dynamic>;
                          if (data.containsKey('message')) {
                            if (data['message'] is String) {
                              message = [data['message']];
                            } else if (data['message'] is List) {
                              message = [data['message']];
                            }
                          }
                        }
                        ComponentCustom.alert(context, message, 'Error');
                      } catch (err) {
                        print(err);
                      }
                    }
                  },
                  child: Text('Send Code'),
                ),
              ],
            ),

            TextFormField(
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please input Email';
                }

                return val.isValidEmail() ? null : 'Please input format email';
              },
              controller: emailController,
              decoration: InputDecoration(
                label: Text(
                  "Email",
                  style: TextStyle(fontSize: 20),
                ),
                suffixIcon: Icon(Icons.email_outlined),
              ),
            ),

            // SizedBox(
            //   height: context.dynamicHeight(0.007),
            // ),
            TextFormField(
              readOnly: lockPass,
              controller: codeController,
              // validator: (val) {
              //   if (emailController.text.isEmpty) return null;
              //   if (emailController.text.isValidEmail() == false) return null;
              //   if (val == null || val.isEmpty) {
              //     return 'Please input';
              //   }
              //   return null;
              // },
              decoration: InputDecoration(
                label: Text(
                  "Code",
                  style: TextStyle(fontSize: 20),
                ),
                suffixIcon: Icon(Icons.key),
              ),
            ),
            SizedBox(
              height: context.dynamicHeight(0.007),
            ),
            TextFormField(
              readOnly: lockPass,
              controller: passController,
              // validator: (val) {
              //   if (emailController.text.isEmpty) return null;
              //   if (emailController.text.isValidEmail() == false) return null;
              //   if (val == null || val.isEmpty) {
              //     return 'Please input';
              //   }
              //   if (passController.text.length < 8) {
              //     return 'Password min 8 character';
              //   }
              //   return null;
              // },
              decoration: InputDecoration(
                label: Text(
                  "New Password",
                  style: TextStyle(fontSize: 20),
                ),
                suffixIcon: Icon(Icons.no_encryption_outlined),
              ),
            ),
            SizedBox(
              height: context.dynamicHeight(0.05),
            ),
            Container(
              width: context.dynamicWidth(1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red.shade800, Colors.black54],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: lockPass
                    ? null
                    : () {
                        processResetPass();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: isLoad
                    ? CircularProgressIndicator()
                    : Text(
                        "Reset Password",
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
    );
  }
}
