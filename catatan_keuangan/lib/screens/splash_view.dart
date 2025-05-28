import 'dart:async';

import 'package:catatan_keuangan/core/enum/auth_enum.dart';

import '../core/bloc/auth/auth_bloc.dart';
import '../core/bloc/auth/auth_event.dart';
import '../extensions/context_entension.dart';
import '../extensions/navigate_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  final GlobalKey<_SplashViewState> myWidgetKey = GlobalKey();
  late final AuthBloc authBloc;
  late StreamSubscription authStream;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    authBloc = context.read<AuthBloc>()..add(AppStarted());
    authStream = authBloc.stream.listen((state) {
      if (state.status == AuthStatus.unknown) return;
      Future.delayed(Duration(seconds: 2), () {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => state.status.firstView));
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    authStream.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        // color: Colors.amber,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.red.shade800, Colors.black54],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: RotationTransition(
          turns: _animation,
          child: Center(
            child: Image.network(
              'https://www.freepnglogos.com/uploads/logo-3d-png/3d-company-logos-design-logo-online-2.png',
              height: context.dynamicHeight(0.2),
              width: context.dynamicWidth(0.9),
            ),
            // child: Image.asset(
            //   IconEnums.appLogo.iconName.toPng,
            // height: context.dynamicHeight(0.2),
            // width: context.dynamicWidth(0.9),
            // ),
          ),
        ),
      ),
    );
  }
}
