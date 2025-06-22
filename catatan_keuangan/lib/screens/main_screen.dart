import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/components/component_custom.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_state.dart';
import 'package:catatan_keuangan/core/bloc/category/category_bloc.dart';
import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/navigate_extension.dart';
import 'package:catatan_keuangan/init/network/dio_manager.dart';
import 'package:catatan_keuangan/screens/modify_transacation_screen.dart';
import 'package:catatan_keuangan/template/chart_daily_screen.dart';
import 'package:catatan_keuangan/template/dailyscreen.dart';
import 'package:catatan_keuangan/template/monthlyscreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
      "label": "Chart",
    }
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
    // try {
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
    setState(() {
      isLoad = true;
    });
    tranStream = tranBloc.stream.listen(listenTrans);

    catBloc = context.read<CategoryBloc>();
    catBloc.add(CategoryStarted());

    catStream = catBloc.stream.listen(listenCat);
    // } catch (err) {}
    if (_tabController.index == 0) {
      setDaily(monthNow, yearNow);
    }

    // print(authBloc.state.status);
  }

  void listenTrans(TransactionState state) {
    if (state.message != null) {
      List message = [];
      if (state.message is List) {
        message.addAll(state.message as List);
      } else {
        message.add(state.message);
      }
      if (context.mounted) {
        ComponentCustom.alert(
          context,
          message,
          'Error',
          callback: () {
            Navigator.of(context).pop();
            tranBloc.add(TransactionCleanMessage());
          },
        );
      }

      // alert(message, 'Error', callback: () {
      //   Navigator.of(context).pop();
      //   tranBloc.add(TransactionCleanMessage());
      // });
      return;
    }
    if (state.loading == false) {
      setState(() {
        isLoad = false;
      });
    } else {
      setState(() {
        isLoad = true;
      });
    }
    if (state.status == AuthStatus.guest) {
      ComponentCustom.alert(
        context,
        ComponentCustom.messageSessionOut,
        'Session Timeout',
        buttonClose: 'Logout',
        callback: () {
          authBloc.add(LogoutRequested());
        },
      );
    }
  }

  void listenCat(CategoryState state) {
    if (state.status == AuthStatus.guest) {
      ComponentCustom.alert(
        context,
        ComponentCustom.messageSessionOut,
        'Session Timeout',
        buttonClose: 'Logout',
        callback: () {
          authBloc.add(LogoutRequested());
        },
      );
    }
  }

  // void alert(List message, String title, {VoidCallback? callback}) {
  //   showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: message.map((e) => Text(e.toString())).toList(),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: callback ??
  //                 () {
  //                   Navigator.of(context).pop();
  //                   tranBloc.add(TransactionCleanMessage());
  //                 },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    removeHighlightOverlay();
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

  // Future<void> _showMyDialog() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Session Timeout'),
  //         content: const SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text('Your session is gone.'),
  //               Text('You must login again'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Logout'),
  //             onPressed: () {
  //               authBloc.add(LogoutRequested());
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
    // isLoad = true;
    setState(() {
      monthNow = month;
      yearNow = year;
      isLoad = true;
    });
    tranBloc.add(TransactionDailyRequested(
        '$year-${month.toString().padLeft(2, '0')}-01'));
  }

  void setMonth(int year) {
    setState(() {
      yearNow = year;
      isLoad = true;
    });
    tranBloc.add(TransactionGetMonthlyData('$year'));
  }

  void setDailyFromHeader(int month, int year) {
    setDaily(month, year);
    removeHighlightOverlay();
  }

  void eventListenerTab() {
    if (isLoad || tranBloc.state.loading) return;
    if (_tabController.index == 0) {
      tranBloc.add(TransactionDailyRequested(
          '$yearNow-${monthNow.toString().padLeft(2, '0')}-01'));
    } else if (_tabController.index == 1) {
      tranBloc.add(TransactionGetMonthlyData('$yearNow'));
    } else if (_tabController.index == 2) {
      setState(() {});
      // tranBloc.add(TransactionDailyRequested(
      //     '$yearNow-${monthNow.toString().padLeft(2, '0')}-01'));
    }
  }

  Future<bool> requestPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final plugin = DeviceInfoPlugin();
      final androidInfo = await plugin.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      // print(sdkInt);
      if (sdkInt >= 33) {
        return true;
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          // Permission.storage.request();
          status = await Permission.storage.request();

          if (!status.isGranted) {
            await openAppSettings();
          }
        }
        return status.isGranted;
      }
    }
    return true; // iOS doesn't require explicit storage permission for app's own directory
  }

  Future<bool> checkFolder() async {
    // DownloadsPath
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        Directory dir = Directory('/storage/emulated/0/Download');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<String?> checkNamingFile(String nameFile) async {
    int i = 0;
    if (Theme.of(context).platform == TargetPlatform.android) {
      Directory dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      while (true) {
        File file = File('$path/$nameFile ${i == 0 ? '' : '($i)'}.csv');
        if (i == 100) return null;
        if (file.existsSync()) {
          i = i + 1;
        } else {
          return '$nameFile ${i == 0 ? '' : '($i)'}.csv';
        }
      }
    }
    return null;
  }

  String path = '/storage/emulated/0/Download';
  void download() async {
    if (isLoad) return;
    String st = '$yearNow-${monthNow.toString().padLeft(2, '0')}-01';
    String ed = DateTime(yearNow, monthNow + 1, 0).yyyymmdd();
    Map<String, String> queryParams = {'start': st, 'end': ed};
    bool permission = await requestPermissions();
    // print(permission);
    if (permission == false) {
      // ignore: use_build_context_synchronously
      ComponentCustom.alert(context, ['Please open Permission'], 'Failed');
      // alert(
      //   ['Please open Permission'],
      //   'Failed',
      // );
      return;
    }
    bool isFolderAvail = await checkFolder();
    if (isFolderAvail == false) {
      return;
    }
    String? nameFile = await checkNamingFile('catatan_keuangan_${st}_$ed');
    nameFile = nameFile ??
        'catatan_keuangan_${st}_${ed}_${DateTime.now().millisecondsSinceEpoch}.csv';

    setState(() {
      isLoad = true;
    });
    try {
      await DioManager.instance.dio.download(
        'transaction/download',
        '$path/$nameFile',
        queryParameters: queryParams,
      );
      ComponentCustom.alert(
        // ignore: use_build_context_synchronously
        context,
        ['Success save', 'You can check in Download Folder'],
        'Success',
      );
      // alert(
      //   ['Success save', 'You can check in Download Folder'],
      //   'Success',
      // );
    } on DioException catch (e) {
      if (e.response?.statusCode == 500 || e.response?.statusCode == 400) {
        List messageShow = [];
        if (e.response?.data != null &&
            e.response?.data is Map<String, dynamic>) {
          Map<String, dynamic> message =
              e.response!.data as Map<String, dynamic>;
          if (message.containsKey('message')) {
            if (message['message'] is String) {
              messageShow = [message['message'] as String];
            } else if (message['message'] is List) {
              messageShow = message['message'] as List;
            }
          }
        }
        ComponentCustom.alert(
          // ignore: use_build_context_synchronously
          context,
          messageShow,
          'Failed',
        );
        // alert(
        //   messageShow,
        //   'Failed',
        // );
      }
    } catch (err) {
      ComponentCustom.alert(
        // ignore: use_build_context_synchronously
        context,
        [err],
        'Failed',
      );
      // alert(
      //   [err],
      //   'Failed',
      // );
    }
    setState(() {
      isLoad = false;
    });
  }

  @override
  Widget build(BuildContext context1) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, stateTran) {
      return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            toolbarHeight: 100,
            iconTheme: IconThemeData(color: Colors.white),
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
                            if (_tabController.index == 0)
                              IconButton(
                                onPressed: () async {
                                  download();
                                },
                                icon: Icon(Icons.download),
                              ),
                            IconButton(
                              onPressed: () {
                                if (_tabController.index == 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ModifyTransactionScreen(
                                        date: '$yearNow-$monthNow',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.add,
                              ),
                            ),
                            IconButton(
                              onPressed: isLoad || stateTran.loading
                                  ? null
                                  : () {
                                      // if (isLoad) return;
                                      if (_tabController.index == 0) {
                                        setDaily(monthNow, yearNow);
                                      } else if (_tabController.index == 1) {
                                        setMonth(yearNow);
                                      } else if (_tabController.index == 2) {
                                        setDaily(monthNow, yearNow);
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
                          if (isLoad || stateTran.loading) return;

                          if (_tabController.index == 0) {
                            if ((monthNow - 1) == 0) {
                              setDaily(12, yearNow - 1);
                            } else {
                              setDaily(monthNow - 1, yearNow);
                            }
                          } else if (_tabController.index == 1) {
                            setMonth(yearNow - 1);
                          } else if (_tabController.index == 2) {
                            if ((monthNow - 1) == 0) {
                              setDaily(12, yearNow - 1);
                            } else {
                              setDaily(monthNow - 1, yearNow);
                            }
                          }
                        },
                        icon: Icon(Icons.chevron_left),
                      ),
                      TextButton(
                        onPressed: () {
                          if (isLoad) return;
                          if (_tabController.index == 0) {
                            startOverlay();
                          } else if (_tabController.index == 2) {
                            startOverlay();
                          }
                        },
                        child: Text(
                          _tabController.index == 1
                              ? yearNow.toString()
                              : DateTime.parse(
                                      '$yearNow-${monthNow.toString().padLeft(2, '0')}-01')
                                  .formatMM3chyyyy(),
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isLoad || stateTran.loading) return;
                          if (_tabController.index == 0) {
                            if ((monthNow + 1) == 13) {
                              setDaily(1, yearNow + 1);
                            } else {
                              setDaily(monthNow + 1, yearNow);
                            }
                          } else if (_tabController.index == 1) {
                            setMonth(yearNow + 1);
                          } else if (_tabController.index == 2) {
                            if ((monthNow + 1) == 13) {
                              setDaily(1, yearNow + 1);
                            } else {
                              setDaily(monthNow + 1, yearNow);
                            }
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
              // physics: isLoad ? NeverScrollableScrollPhysics() : null,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              tabs: _tabs,
              controller: _tabController,
            ),
          ),
          drawer: ComponentCustom.drawerCustom(context, 0, bloc: authBloc),
          body: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                // children: tab_name.map((e) => e['screen'] as Widget).toList(),
                children: [
                  DailyScreen(),
                  MonthlyScreen(),
                  ChartDailyScreen()
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
    });
  }
}
