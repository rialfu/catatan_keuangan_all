import 'dart:async';

import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/constants/message_custom.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/enum/biometric_enum.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/init/cache/auth_cache_manager.dart';
import 'package:catatan_keuangan/screens/notifier/authenticate_screen_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import '../extensions/context_entension.dart';

class LoginComponent extends StatefulWidget {
  final AuthenticateScreenNotifier? notifier;
  const LoginComponent({super.key, this.notifier});

  @override
  State<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final _signInGlobalKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController emailController = TextEditingController(text: '');
  bool hidePass = true;
  late StreamSubscription stream;
  final LocalAuthentication auth = LocalAuthentication();
  BiometricSupportState isDeviceSupport = BiometricSupportState.unknown;
  late AuthenticateScreenNotifier notifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var bloc = context.read<AuthBloc>();
    setIsDeviceSupport();
    stream = bloc.stream.listen(listening);
    notifier = context.read<AuthenticateScreenNotifier>();
    notifier.addListener(listenNotifier);
    _googleSignIn = GoogleSignIn(
      scopes: scopes,
      serverClientId:
          '990321993205-sk2p5hjpdgvamdl9v7ig6if5mmcslp09.apps.googleusercontent.com',
    );
  }

  @override
  void dispose() {
    // widget.notifier?.removeListener(listenNotifier);
    notifier.removeListener(listenNotifier);
    // notifier.dispose();
    stream.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void listenNotifier() {
    if (notifier.page == 'login') {
      emailController.text = '';
      passwordController.text = '';
    }
  }

  List<String> scopes = <String>[
    // 'email',
    'openid',
    // 'profi',
  ];
  late GoogleSignIn _googleSignIn;

  Future<void> setIsDeviceSupport({bool initial = false}) async {
    // auth.authenticate(localizedReason: localizedReason)
    bool res = await auth.isDeviceSupported();
    setState(() {
      isDeviceSupport = res
          ? BiometricSupportState.supported
          : BiometricSupportState.unsupported;
    });
  }

  Future<void> listening(AuthState state) async {
    String titleMessage = "Error";
    List<String> message = [MessageCustom.serverNotActive];
    // String message = "App couldnt connect to server";
    if (state.error == AuthError.hostUnreachable) {
    } else if (state.error == AuthError.wrongEmailOrPassword) {
      message = ["Username or Password is wrong"];
    } else if (state.error == AuthError.unknown) {
      message = ["App crash, please reinstall or call developer"];
    } else if (state.error == AuthError.wrongEmailOrPasswordBiometric) {
      message = [
        "Username or Password is not match",
        "Please use standart login"
      ];
    } else if (state.error == AuthError.failedGoogleSSO) {
      message = [
        "Something is wrong with System or Google",
        "Please Try again or use standart login"
      ];
    }

    if (state.error == AuthError.wrongEmailOrPassword ||
        state.error == AuthError.hostUnreachable ||
        state.error == AuthError.wrongEmailOrPasswordBiometric ||
        state.error == AuthError.failedGoogleSSO) {
      ComponentCustom.alert(
        context,
        message,
        titleMessage,
        callback: () {
          var bloc = context.read<AuthBloc>();
          bloc.add(CleanAuthRequest());
          Navigator.of(context).pop();
        },
      );
    }
  }

  Future<void> openForgot() async {
    context.read<AuthenticateScreenNotifier>().closeLogin();

    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    context.read<AuthenticateScreenNotifier>().openResetPass();
    FocusScope.of(context).unfocus();
  }

  Future<void> loginBiometrict(AuthState stateBloc) async {
    if (stateBloc.isLoad) return;
    if (isDeviceSupport == BiometricSupportState.unsupported) {
      ComponentCustom.alert(
        context,
        ['Your device is not support biometric'],
        'Alert',
      );

      return;
    } else if (isDeviceSupport == BiometricSupportState.unknown) {
      setIsDeviceSupport();
      return;
    }
    bool isAuthenticate = false;
    try {
      isAuthenticate = await auth.authenticate(
        localizedReason: 'Please put your biometric',
        options: AuthenticationOptions(
          useErrorDialogs: false,
          biometricOnly: true,
        ),
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required!',
            cancelButton: 'No thanks',
          )
        ],
      );
    } on PlatformException catch (e) {
      String message = e.toString();
      if (e.code == auth_error.passcodeNotSet) {
        message = 'Your device not configure';
      } else if (e.code == auth_error.notAvailable) {
        message = 'Your device not support';
      }
      if (!mounted) return;
      ComponentCustom.alert(
        context,
        [message],
        'Alert',
      );
      return;
    } catch (err) {
      if (!mounted) return;
      ComponentCustom.alert(
        context,
        ["Something is wrong"],
        'Alert',
      );
      return;
    }

    if (isAuthenticate == false) return;
    var acm = AuthCacheManager();
    var data = await acm.getAuth();

    if (data == null) return;
    if (!data.containsKey('email')) return;
    if (!data.containsKey('password')) return;
    if (!mounted) return;
    context.read<AuthBloc>().add(
          LoginRequestedWithBiometric(
            data['email'],
            data['password'],
          ),
        );
  }

  Future<void> signWithGoogle() async {
    if (await _googleSignIn.isSignedIn()) {
      _googleSignIn.signOut();
    }
    try {
      var res = await _googleSignIn.signIn();
      if (res == null) return;
      var auth = await res.authentication;
      if (!mounted) return;
      String token = auth.idToken ?? '';
      if (token == '') {
        ComponentCustom.alert(
            context, ['Gagal mendapatkan verifikasi dari google'], 'error');
      }

      var bloc = context.read<AuthBloc>();
      bloc.add(LoginWithGoogleSSO(token, res.email));
    } catch (err) {
      if (!mounted) return;
      ComponentCustom.alert(context, ['token:$err'], 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        // stream: null,
        builder: (context, stateBloc) {
      return SingleChildScrollView(
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
                  suffixIcon: Icon(Icons.email_outlined),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: openForgot,
                  child: Text('forgot password'),
                ),
              ),
              SizedBox(
                height: context.dynamicHeight(0.02),
              ),
              Row(
                children: [
                  Expanded(
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
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
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
                    child: IconButton(
                      onPressed: () async {
                        // st
                        loginBiometrict(stateBloc);
                      },
                      icon: Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              TextButton(
                  onPressed: () {
                    signWithGoogle();
                  },
                  child: Text("google"))
            ],
          ),
        ),
      );
    });
  }
}
