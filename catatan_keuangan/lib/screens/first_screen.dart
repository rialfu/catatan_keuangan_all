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
      // if(state.status )
      if (state is LoginState) {
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
      // Stack(
      //   children: [
      //     ElevatedButton(
      //         onPressed: () {
      //           setState(() {
      //             hidePass = !hidePass;
      //           });
      //         },
      //         child: Text("click" + (hidePass ? "d" : "s"))),
      //     AnimatedPositioned(
      //       bottom: 0,
      //       width: context.dynamicWidth(1),
      //       height: hidePass ? 0 : context.dynamicHeight(0.5),
      //       child: Container(
      //         width: 50,
      //         height: 20,
      //         color: Colors.black,
      //       ),
      //       duration: Duration(seconds: 1),
      //     ),
      //   ],
      // ),
      // child: Stack(
      //   children: [
      //     Animate(
      //       target: formSignUp ? 1 : 0,
      //       effects: [
      //         FadeEffect(
      //             // duration: Duration(microseconds: 500),
      //             ),
      //         SlideEffect(
      //           begin: Offset(50, 0),
      //           end: Offset(0, 0),
      //           // duration: Duration(milliseconds: 500),
      //         )
      //       ],
      //       child: Column(
      //         children: [
      //           Expanded(
      //             child: ,
      //           ),
      //           ElevatedButton(
      //               onPressed: () {
      //                 setState(() {
      //                   formSignIn = !formSignIn;
      //                   formSignUp = !formSignUp;
      //                 });
      //               },
      //               child: Text("back"))
      //         ],
      //       ),
      //     ),
      //     Animate(
      //       target: formSignIn ? 1 : 0,
      //       // delay: Duration(seconds: 1),
      //       effects: [
      //         FadeEffect(
      //             // duration: Duration(microseconds: 500),
      //             ),
      //         SlideEffect(
      //           begin: Offset(-50, 0),
      //           end: Offset(0, 0),
      //           // duration: Duration(microseconds: 500),
      //         )
      //       ],
      //       child: Column(
      //         children: [
      //           Expanded(
      //             flex: 2,
      //             child: const Center(
      //               child: Text(
      //                 "Welcome back!\nSign in to continue!",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(
      //                   fontSize: 30,
      //                 ),
      //               ),
      //             ),
      //           ),
      //           Expanded(
      //             flex: 1,
      //             child: FittedBox(
      //               fit: BoxFit.fill,
      //               child: Image.network(
      //                 'https://www.freepnglogos.com/uploads/logo-3d-png/3d-company-logos-design-logo-online-2.png',
      //                 // width: 40,
      //               ),
      //             ),
      //           ),
      //           Expanded(
      //             flex: 4,
      //             child: Form(
      //               key: _signInGlobalKey,
      //               child: Column(
      //                 children: [
      //                   TextFormField(
      //                     controller: emailController,
      //                     validator: (value) {
      //                       if (value == null ||
      //                           !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      //                               .hasMatch(value)) {
      //                         return 'Enter a valid email!';
      //                       }
      //                       return null;
      //                     },
      //                     decoration: const InputDecoration(
      //                       hintText: "email address",
      //                       prefixIcon: Icon(Icons.email),
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                   TextFormField(
      //                     controller: passwordController,
      //                     obscureText: hidePass,
      //                     validator: (value) {
      //                       return null;
      //                     },
      //                     decoration: InputDecoration(
      //                       hintText: "Pasword",
      //                       prefixIcon: Icon(Icons.lock),
      //                       suffixIcon: GestureDetector(
      //                         onTap: () {
      //                           // passwordSee = !passwordSee;
      //                           setState(() {
      //                             hidePass = !hidePass;
      //                           });
      //                         },
      //                         child: Icon(
      //                           hidePass
      //                               ? Icons.visibility_off_outlined
      //                               : Icons.visibility_outlined,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.end,
      //                     children: [
      //                       TextButton(
      //                         onPressed: () {},
      //                         style: TextButton.styleFrom(
      //                           padding: EdgeInsets.zero,
      //                           minimumSize: Size.zero,
      //                         ),
      //                         child: Text("forgot password"),
      //                       )
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   ElevatedButton(
      //                     style: ElevatedButton.styleFrom(
      //                         backgroundColor: Colors.blueGrey,
      //                         // text,
      //                         fixedSize: Size(context.dynamicWidth(1), 50)),
      //                     onPressed: () {},
      //                     child: Text(
      //                       "Sign In",
      //                       style:
      //                           TextStyle(color: Colors.white, fontSize: 20),
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   TextButton(
      //                     onPressed: () {
      //                       setState(() {
      //                         formSignIn = !formSignIn;
      //                         formSignUp = !formSignUp;
      //                       });
      //                     },
      //                     child: Text("You don't have Account?"),
      //                   )
      //                 ],
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //     )
      //   ],
      // ),
      // child: Container(
      //   color: Colors.red,
      // ),
      // child: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20),
      //   child: Stack(
      //     children: [
      //       Animate(
      //         target: ani ? 1 : 0,
      //         effects: [
      //           FadeEffect(),
      //           SlideEffect(begin: Offset(2, 0), end: Offset(0, 0))
      //         ],
      //         child: Column(
      //           children: [
      //             Expanded(
      //               flex: 2,
      //               child: const Center(
      //                 child: Text(
      //                   "Hello, you can signUp",
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     fontSize: 30,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             Expanded(
      //               flex: 3,
      //               child: Form(
      //                 key: _signUpGlobalKey,
      //                 child: Column(
      //                   children: [],
      //                 ),
      //               ),
      //             ),
      //             ElevatedButton(
      //                 onPressed: () {
      //                   setState(() {
      //                     ani = !ani;
      //                   });
      //                 },
      //                 child: Text("balik"))
      //           ],
      //         ),
      //       ),
      //       Animate(
      //         target: ani ? 0 : 1,
      //         effects: [
      //           FadeEffect(),
      //           SlideEffect(begin: Offset(-2, 0), end: Offset(0, 0))
      //         ],
      //         child: Column(
      //           children: [
      //             Expanded(
      //               flex: 2,
      //               child: const Center(
      //                 child: Text(
      //                   "Welcome back!\nSign in to continue!",
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     fontSize: 30,
      //                   ),
      //                 ),
      //               ),
      //             ),
      //             Expanded(
      //               flex: 2,
      //               child: FittedBox(
      //                 fit: BoxFit.fill,
      //                 child: Image.network(
      //                   'https://www.freepnglogos.com/uploads/logo-3d-png/3d-company-logos-design-logo-online-2.png',
      //                   // width: 40,
      //                 ),
      //               ),
      //             ),

      //             Expanded(
      //               flex: 2,
      //               child: Form(
      //                 key: _signInGlobalKey,
      //                 child: Column(
      //                   children: [
      //                     TextFormField(
      //                       controller: emailController,
      //                       validator: (value) {
      //                         if (value == null ||
      //                             !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      //                                 .hasMatch(value)) {
      //                           return 'Enter a valid email!';
      //                         }
      //                         return null;
      //                       },
      //                       decoration: const InputDecoration(
      //                           hintText: "email address"),
      //                     ),
      //                     const SizedBox(height: 30),
      //                     TextFormField(
      //                       controller: passwordController,
      //                       obscureText: hidePass,
      //                       // validator: AuthValidator.isPasswordValid,
      //                       decoration: InputDecoration(
      //                         hintText: "password",
      //                         suffixIcon: GestureDetector(
      //                           onTap: () {
      //                             // passwordSee = !passwordSee;
      //                             setState(() {
      //                               hidePass = !hidePass;
      //                             });
      //                           },
      //                           child: Icon(
      //                             hidePass
      //                                 ? Icons.visibility_off_outlined
      //                                 : Icons.visibility_outlined,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //             Expanded(
      //               flex: 2,
      //               child: Column(
      //                 children: [
      //                   MyButtonTwo(
      //                     text: "Log in",
      //                     onPressed: () {
      //                       setState(() {
      //                         ani = !ani;
      //                       });
      //                     },
      //                     sizeFont: 18,
      //                   ),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                     children: [
      //                       TextButton(
      //                         child: Text(
      //                           "Sign Up",
      //                           style: TextStyle(
      //                             fontWeight: FontWeight.w500,
      //                             fontSize: 18,
      //                             color: Color(0xFF265AE8),
      //                           ),
      //                         ),
      //                         onPressed: () {},
      //                       ),
      //                       TextButton(
      //                         child: Text(
      //                           "Forgot Password",
      //                           style: TextStyle(
      //                             fontWeight: FontWeight.w500,
      //                             fontSize: 18,
      //                             color: Color(0xFF265AE8),
      //                           ),
      //                         ),
      //                         onPressed: () {},
      //                       ),
      //                     ],
      //                   )
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
