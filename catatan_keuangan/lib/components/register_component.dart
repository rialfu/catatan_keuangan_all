import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:catatan_keuangan/screens/notifier/authenticate_screen_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../extensions/context_entension.dart';

class RegisterComponent extends StatefulWidget {
  final AuthenticateScreenNotifier? notifier;
  const RegisterComponent({super.key, this.notifier});

  @override
  State<RegisterComponent> createState() => _RegisterComponentState();
}

class _RegisterComponentState extends State<RegisterComponent> {
  final _signInGlobalKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool hidePass = true;
  bool isLoad = false;
  // String pattern = r'[a-z0-9A-Z\.]+@[a-zA-Z]+\.(com|co.id|go.id)';
  String pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

  late AuthenticateScreenNotifier notifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifier = context.read<AuthenticateScreenNotifier>();
    notifier.addListener(listenNotifier);
    widget.notifier?.addListener(listenNotifier);
  }

  Future<void> register(BuildContext contextD) async {
    setState(() {
      isLoad = true;
    });
    // var dio = Dio();
    try {
      await DioManager.instance.dio.post('create-account', data: {
        'email': emailController.text,
        'name': nameController.text,
        'password': passwordController.text
      });
      if (contextD.mounted) {
        ComponentCustom.alert(
          contextD,
          ['Success add new data'],
          'Success Info',
        );
        // showMessage(contextD, ['Success add new data'], 'Success Info');
      }
    } on DioException catch (e) {
      List<String> message = CustomResponseError.buildResponseFromServer(e);
      ComponentCustom.alert(contextD, message, 'Error');
    } catch (err) {
      ComponentCustom.alert(contextD, [err.toString()], 'Error');
      // showMessage(contextD, [err.toString()], 'Error');
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  void dispose() {
    // widget.notifier?.removeListener(listenNotifier);
    notifier.removeListener(listenNotifier);
    // notifier.dispose();
    emailController.dispose();
    passwordController.dispose();
    confPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void listenNotifier() {
    if (notifier.page == 'register') {
      _signInGlobalKey.currentState?.reset();
      emailController.text = '';
      passwordController.text = '';
      confPasswordController.text = '';
      nameController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _signInGlobalKey,
        child: Column(
          children: [
            SizedBox(
              height: context.dynamicHeight(0.05),
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
                  style: TextStyle(fontSize: context.fontSizeBasedScreen(0.8)),
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
                  style: TextStyle(fontSize: context.fontSizeBasedScreen(0.8)),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      hidePass = !hidePass;
                    });
                  },
                  child: Icon(
                    hidePass ? Icons.visibility_off : Icons.visibility_outlined,
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
                  style: TextStyle(fontSize: context.fontSizeBasedScreen(0.8)),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      hidePass = !hidePass;
                    });
                  },
                  child: Icon(
                    hidePass ? Icons.visibility_off : Icons.visibility_outlined,
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
                  colors: [Colors.red, Colors.red.shade800, Colors.black54],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (isLoad) return;
                  if (_signInGlobalKey.currentState?.validate() ?? false) {
                    register(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: isLoad
                    ? CircularProgressIndicator()
                    : Text(
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
    );
  }
}
