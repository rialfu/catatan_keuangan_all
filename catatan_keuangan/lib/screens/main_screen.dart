import 'dart:async';

import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/screens/saving_plan_screen.dart';
import 'package:catatan_keuangan/template/categoryscreen.dart';
import 'package:catatan_keuangan/template/dailyscreen.dart';
import 'package:catatan_keuangan/template/monthlyscreen.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> tabName = [
    {
      "label": "Daily",
    },
    // {"label": "Weekly"},
    {
      "label": "Monthly",
    },
    {
      "label": "Categories",
    }
    // {"label": "Yearly"}
  ];

  List<Tab> _tabs = [];
  late TabController _tabController;
  late final AuthBloc authBloc;
  late StreamSubscription authStream;

  late final TransactionBloc tranBloc;
  late StreamSubscription tranStream;

  late final CategoryBloc catBloc;
  late StreamSubscription catStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabs = _getTabs(tabName);
    _tabController = TabController(length: _tabs.length, vsync: this);
    try {
      authBloc = context.read<AuthBloc>();
      authStream = authBloc.stream.listen((state) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => state.status.firstView,
            ),
          );
        }
      });
      tranBloc = context.read<TransactionBloc>();
      // print('tran bloc start');
      tranBloc.add(TransactionStarted());
      tranStream = tranBloc.stream.listen((state) {
        if (state.status == AuthStatus.guest) {
          _showMyDialog();
        }
      });
      catBloc = context.read<CategoryBloc>();
      catBloc.add(CategoryStarted());
      catStream = catBloc.stream.listen((state) {
        if (state.status == AuthStatus.guest) {
          _showMyDialog();
        }
      });
    } catch (err) {
      print('err');
      print(err);
    }

    // print(authBloc.state.status);
  }

  @override
  void dispose() {
    tranStream.cancel();
    authStream.cancel();
    catStream.cancel();

    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> _getTabs(List<Map<String, dynamic>> modules) {
    return modules.map((module) {
      return Tab(
        text: module["label"],
      );
    }).toList();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Timeout'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your session is gone.'),
                Text('You must login again'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                authBloc.add(LogoutRequested());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.red,
          title: Container(
            // color: Colors.red,
            width: context.dynamicWidth(1),
            // color: Colors.orange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome ${state.name}',
                  style: TextStyle(color: Colors.white),
                ),
                // IconButton(
                //     onPressed: () {
                //       authBloc.add(LogoutRequested());
                //     },
                //     icon: Icon(
                //       Icons.logout,
                //       color: Colors.white,
                //     ))
              ],
            ),
          ),
          bottom: TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: _tabs,
            controller: _tabController,
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text("Home / Catatan"),
                onTap: () {
                  // Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              ListTile(
                title: Text("Saving Plan"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavingPlanScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text("Log out"),
                onTap: () {
                  authBloc.add(LogoutRequested());
                },
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          // children: tab_name.map((e) => e['screen'] as Widget).toList(),
          children: [
            DailyScreen(),
            // Container(
            //   child: Text("We"),
            // ),
            MonthlyScreen(),
            // Container(
            //   child: Text("Y"),
            // ),
            CategoryScreen(),
          ],
        ),
      );
    });
  }
}
