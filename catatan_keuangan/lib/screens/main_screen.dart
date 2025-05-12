import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/screens/modify_transacation_screen.dart';
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
    // {
    //   "label": "Categories",
    // }
    // {"label": "Yearly"}
  ];
  bool isLoad = false;
  List<Tab> _tabs = [];
  late TabController _tabController;
  late final AuthBloc authBloc;
  late StreamSubscription authStream;

  late final TransactionBloc tranBloc;
  late StreamSubscription tranStream;

  late final CategoryBloc catBloc;
  late StreamSubscription catStream;

  late int yearNow;
  late int monthNow;
  OverlayEntry? overlayEntry;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabs = _getTabs(tabName);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(eventListenerTab);
    yearNow = DateTime.now().year;
    monthNow = DateTime.now().month;
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
      //transaction
      tranBloc = context.read<TransactionBloc>();
      tranBloc.add(TransactionStarted());
      tranStream = tranBloc.stream.listen((state) {
        if (state.message != null) {
          List message = [];
          if (state.message is List) {
            message.addAll(state.message as List);
          } else {
            message.add(state.message);
          }
          showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
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
                      tranBloc.add(TransactionCleanMessage());
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
        if (state is TransactionStateLoading) {
          setState(() {
            isLoad = true;
          });
        } else if (state is TransactionStateFinishLoad) {
          setState(() {
            isLoad = false;
          });
        } else if (state.status == AuthStatus.guest) {
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
    } catch (err) {}
    if (_tabController.index == 0) {
      setDaily(monthNow, yearNow);
    }

    // print(authBloc.state.status);
  }

  @override
  void dispose() {
    tranStream.cancel();
    authStream.cancel();
    catStream.cancel();
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

  int cacheYear = 0;
  Future<void> startOverlay() async {
    setState(() {
      cacheYear = yearNow;
    });

    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        return Positioned.fill(
          child: Container(
            // padding: EdgeInsets.only(top: 100, left: 20),
            // color: Color.fromARGB((0.5 * 255).round(), 0, 0, 0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 50, left: 20),
                  color: Colors.red,
                  width: context.dynamicWidth(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cacheYear = cacheYear - 1;
                          });
                          overlayEntry?.markNeedsBuild();
                        },
                        icon: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          removeHighlightOverlay();
                        },
                        child: Text(
                          cacheYear.toString(),
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            cacheYear = cacheYear + 1;
                          });
                          overlayEntry?.markNeedsBuild();
                        },
                        icon: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 17,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(
                    bottom: 20,
                  ),
                  width: context.dynamicWidth(1),
                  child: Row(
                    children: [
                      templateHeader1(() {
                        setDailyFromHeader(1, cacheYear);
                      }, 'Jan'),
                      templateHeader1(() {
                        setDailyFromHeader(2, cacheYear);
                      }, 'Feb'),
                      templateHeader1(() {
                        setDailyFromHeader(3, cacheYear);
                      }, 'Mar'),
                      templateHeader1(() {
                        setDailyFromHeader(4, cacheYear);
                      }, 'Apr'),
                      templateHeader1(() {
                        setDailyFromHeader(5, cacheYear);
                      }, 'May'),
                      templateHeader1(() {
                        setDailyFromHeader(6, cacheYear);
                      }, 'Jun'),
                    ],
                  ),
                ),
                Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(
                    bottom: 20,
                  ),
                  width: context.dynamicWidth(1),
                  child: Row(
                    children: [
                      templateHeader1(() {
                        setDailyFromHeader(7, cacheYear);
                      }, 'Jul'),
                      templateHeader1(() {
                        setDailyFromHeader(8, cacheYear);
                      }, 'Aug'),
                      templateHeader1(() {
                        setDailyFromHeader(9, cacheYear);
                      }, 'Sept'),
                      templateHeader1(() {
                        setDailyFromHeader(10, cacheYear);
                      }, 'Oct'),
                      templateHeader1(() {
                        setDailyFromHeader(11, cacheYear);
                      }, 'Nov'),
                      templateHeader1(() {
                        setDailyFromHeader(12, cacheYear);
                      }, 'Dec'),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      removeHighlightOverlay();
                    },
                    child: Container(
                      color: Color.fromARGB((0.5 * 255).round(), 0, 0, 0),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void removeHighlightOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  Widget templateHeader1(Function() event, String name) {
    return Expanded(
      child: GestureDetector(
        onTap: event,
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  void setDaily(int month, int year) {
    setState(() {
      monthNow = month;
      yearNow = year;
    });
    tranBloc.add(TransactionDailyRequested(
        '$year-${month.toString().padLeft(2, '0')}-01'));
  }

  void setMonth(int year) {
    setState(() {
      yearNow = year;
    });
    tranBloc.add(TransactionGetMonthlyData('$year'));
  }

  void setDailyFromHeader(int month, int year) {
    setDaily(month, year);
    removeHighlightOverlay();
  }

  void eventListenerTab() {
    if (isLoad) return;
    if (_tabController.index == 0) {
      tranBloc.add(TransactionDailyRequested(
          '$yearNow-${monthNow.toString().padLeft(2, '0')}-01'));
    } else if (_tabController.index == 1) {
      tranBloc.add(TransactionGetMonthlyData('$yearNow'));
    }
  }

  @override
  Widget build(BuildContext context1) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.red,
          toolbarHeight: 100,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Container(
            // height: 120,
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            width: context.dynamicWidth(1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AutoSizeText(
                        'Welcome ${state.name}',
                        maxLines: 2,
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_tabController.index == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ModifyTransactionScreen(),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.add,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (isLoad) return;
                              if (_tabController.index == 0) {
                                setDaily(monthNow, yearNow);
                              } else if (_tabController.index == 1) {
                                setMonth(yearNow);
                              }
                            },
                            icon: Icon(
                              Icons.refresh,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              return IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      // padding: EdgeInsets.zero,
                      onPressed: () {
                        if (isLoad) return;
                        if (_tabController.index == 0) {
                          if ((monthNow - 1) == 0) {
                            setDaily(12, yearNow - 1);
                          } else {
                            setDaily(monthNow - 1, yearNow);
                          }
                        } else if (_tabController.index == 1) {
                          setMonth(yearNow - 1);
                        }
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                    TextButton(
                      onPressed: () {
                        if (isLoad) return;
                        if (_tabController.index == 0) {
                          startOverlay();
                        }
                      },
                      child: Text(
                        _tabController.index == 1
                            ? yearNow.toString()
                            : DateTime.parse(
                                    '$yearNow-${monthNow.toString().padLeft(2, '0')}-01')
                                .MM3chyyyy(),
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (isLoad) return;
                        if (_tabController.index == 0) {
                          if ((monthNow + 1) == 13) {
                            setDaily(1, yearNow + 1);
                          } else {
                            setDaily(monthNow + 1, yearNow);
                          }
                        } else if (_tabController.index == 1) {
                          setMonth(yearNow + 1);
                        }
                      },
                      icon: Icon(Icons.chevron_right),
                    )
                  ],
                ),
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
                  print(isLoad);
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
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              // children: tab_name.map((e) => e['screen'] as Widget).toList(),
              children: [
                DailyScreen(),
                MonthlyScreen(),
                // CategoryScreen(),
              ],
            ),
            isLoad
                ? Container(
                    color: Colors.transparent,
                    width: context.dynamicWidth(1),
                    height: context.dynamicHeight(1),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container()
          ],
        ),
      );
    });
  }
}
