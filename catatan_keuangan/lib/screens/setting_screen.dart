// ignore_for_file: use_build_context_synchronously

import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/service/auth_service.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/init/cache/auth_cache_manager.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
// ignore: depend_on_referenced_packages
import 'package:local_auth_android/local_auth_android.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _SettingScreenState extends State<SettingScreen> {
  bool isBiometricOn = false;
  final LocalAuthentication auth = LocalAuthentication();
  final WidgetStateProperty<Color?> trackColor =
      WidgetStateProperty<Color?>.fromMap(
    <WidgetStatesConstraint, Color>{WidgetState.selected: Colors.green},
  );
  _SupportState _supportState = _SupportState.unknown;
  AuthCacheManager authCacheManager = AuthCacheManager();
  OverlayEntry? overlayEntry;
  bool isCheckAccount = false;
  TextEditingController passController = TextEditingController();
  int tryInput = 0;
  List<String> messages = [];
  AuthCacheManager acm = AuthCacheManager();
  @override
  void initState() {
    super.initState();
    setIsDeviceSupport(initial: true);
  }

  @override
  void dispose() {
    removeHighlightOverlay();
    passController.dispose();
    super.dispose();
  }

  Future<void> setBiometricIsActive() async {
    var authSaved = await authCacheManager.getAuth();
    if (authSaved == null) {
      setState(() {
        isBiometricOn = false;
      });
      return;
    }
    if (!authSaved.containsKey('email')) {
      authCacheManager.clearAuth();
      setState(() {
        isBiometricOn = false;
      });
      return;
    }
    setState(() {
      isBiometricOn = true;
    });
  }

  Future<void> setIsDeviceSupport({bool initial = false}) async {
    // auth.authenticate(localizedReason: localizedReason)
    bool res = await auth.isDeviceSupported();
    setState(() {
      _supportState = res ? _SupportState.supported : _SupportState.unsupported;
    });
    if (initial) {
      setBiometricIsActive();
    }
  }

  void startOverlay() {
    setState(() {
      messages = [];
    });
    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        return Positioned.fill(
          child: Container(
            width: context.dynamicWidth(1),
            height: context.dynamicHeight(1),
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      removeHighlightOverlay();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                Center(
                  child: Material(
                    child: Container(
                      // color: Colors.white,
                      width: context.dynamicWidth(0.8),
                      height: 200,

                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              color: Colors.red,
                            ),
                          ),
                          if (messages.isNotEmpty)
                            SizedBox(
                              child: Column(
                                children: messages
                                    .map((e) => Text(
                                          e,
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text('Password'),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: passController,
                                      decoration: const InputDecoration(
                                          // border: InputBorder.none,
                                          // enabledBorder: InputBorder.none,
                                          // focusedBorder: InputBorder.none,

                                          // labelText: 'Enter your username',
                                          ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              // color: Colors.yellow,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        backgroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        removeHighlightOverlay();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        backgroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        verifyPassword();
                                      },
                                      child: Text('Process'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void removeHighlightOverlay() {
    passController.text = '';
    messages = [];
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  Future<void> verifyPassword() async {
    if (passController.text == '') return;
    if (isCheckAccount) return;
    List messageError = [];

    setState(() {
      isCheckAccount = true;
      messages = [];
      // tryInput = tryInput + 1;
    });
    overlayEntry?.markNeedsBuild();
    // String email = emailController.text;

    try {
      String pass = passController.text;
      var service = AuthService(DioManager.instance);
      var data = await service.verifyPassword(pass);
      // print(data);
      await acm.setAuth({'email': data['email'], 'password': pass});
      removeHighlightOverlay();
      passController.text = '';
      ComponentCustom.alert(
        context,
        ['Success add biometric'],
        'Success',
      );
      setState(() {
        isBiometricOn = true;
        isCheckAccount = false;
      });
      return;
    } on CustomExceptionForPost catch (err) {
      if (err.codeError == 401) {
        removeHighlightOverlay();
        ComponentCustom.alert(
          context,
          ComponentCustom.messageSessionOut,
          'Session Timeout',
          buttonClose: 'Logout',
          callback: () {
            var authBloc = context.read<AuthBloc>();
            authBloc.add(LogoutRequested());
          },
        );
        return;
      }

      if (err.cause is List) {
        messageError = err.cause;
      } else if (err.cause is String) {
        messageError = [err.cause];
      } else {
        messageError = ['The app has been problem'];
      }
    }

    setState(() {
      isCheckAccount = false;
      messages = messageError.map((e) => e.toString()).toList();
    });
    overlayEntry?.markNeedsBuild();
    // if (email == '2') {
  }

  Future<void> setupAuthFingerPrint() async {
    if (_supportState == _SupportState.unsupported) {
      ComponentCustom.alert(
        context,
        ['Your device is not support biometric'],
        'Alert',
      );

      return;
    } else if (_supportState == _SupportState.unknown) {
      setIsDeviceSupport();
      return;
    }

    if (isBiometricOn) {
      acm.clearAuth();
      setState(() {
        isBiometricOn = false;
      });
      return;
    }
    // startOverlay();
    // return;
    try {
      bool isAuthenticate = await auth.authenticate(
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

      if (isAuthenticate == false) return;
      startOverlay();
    } on PlatformException catch (e) {
      String message = e.toString();
      if (e.code == auth_error.passcodeNotSet) {
        message = 'Your device not configure';
      } else if (e.code == auth_error.notAvailable) {
        message = 'Your device not support';
      }
      ComponentCustom.alert(
        context,
        [message],
        'Alert',
      );
    } catch (err) {
      ComponentCustom.alert(
        context,
        ["Something is wrong"],
        'Alert',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Setting"),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Auth Fingerprint"),
                Switch(
                  value: isBiometricOn,
                  trackColor: trackColor,
                  onChanged: (value) async {
                    setupAuthFingerPrint();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
