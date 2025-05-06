import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_bloc.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/screens/detail_saving_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingPlanScreen extends StatefulWidget {
  const SavingPlanScreen({super.key});

  @override
  State<SavingPlanScreen> createState() => _SavingPlanScreenState();
}

class _SavingPlanScreenState extends State<SavingPlanScreen> {
  late final SavingPlanBloc savingPlanBloc;
  late final authBloc;
  late StreamSubscription spStream;
  bool isLoad = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    try {
      savingPlanBloc = context.read<SavingPlanBloc>();
      savingPlanBloc.add(SavingPlanRequested());

      spStream = savingPlanBloc.stream.listen((state) {
        if (state.status == AuthStatus.guest) {
          _showMyDialog();
        } else if (state.loading == false) {
          setState(() {
            isLoad = false;
          });
        }
      });

      authBloc = context.read<AuthBloc>();
    } catch (err) {}
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
  void dispose() {
    spStream.cancel();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: Text(
          "Saving Plan",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<SavingPlanBloc, SavingPlanState>(
          builder: (context, stateBloc) {
        return Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: context.dynamicWidth(0.4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: isLoad
                                ? null
                                : () {
                                    setState(() {
                                      isLoad = true;
                                    });
                                    savingPlanBloc.add(SavingPlanRequested());
                                  },
                            child: Text(
                              "Refresh",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: ListView.builder(
                      itemCount: stateBloc.savingPlans.length,
                      itemBuilder: (context, index) {
                        return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(width: index == 0 ? 1 : 0),
                                bottom: BorderSide(width: 1),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stateBloc.savingPlans[index].name,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        // ${stateBloc.savingPlans[index].typeReminder == 'monthly' || stateBloc.savingPlans[index].typeReminder == 'weekly' ? stateBloc.savingPlans[index].dateReminder : ''}
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Reminder: ${stateBloc.savingPlans[index].typeReminder}',
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          stateBloc.savingPlans[index]
                                                      .dateReminder !=
                                                  null
                                              ? Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'set: ${stateBloc.savingPlans[index].dateReminder ?? ''}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ))
                                              : SizedBox(),

                                          Expanded(child: Container()),
                                          // Text(
                                          //     ': ${stateBloc.savingPlans[index].targetMoney},'),
                                        ],
                                      ),
                                      Text(
                                        'Target Date: ${stateBloc.savingPlans[index].targetDate}',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      AutoSizeText(
                                          maxLines: 1,
                                          'Target Money: ${stateBloc.savingPlans[index].targetMoney.toString().formatMoney()}'),
                                      AutoSizeText(
                                          maxLines: 1,
                                          'Remaining: ${(stateBloc.savingPlans[index].targetMoney - stateBloc.savingPlans[index].checkout.fold(0.0, (previous, current) => previous + current.money)).toString().formatMoney()} '),

                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //       flex: 4,
                                      //       child: AutoSizeText(
                                      //           maxLines: 1,
                                      //           'Target Money: ${stateBloc.savingPlans[index].targetMoney.toString().formatMoney()}'),
                                      //     ),
                                      //     Expanded(
                                      //       flex: 4,
                                      //       child: AutoSizeText(
                                      //           maxLines: 1,
                                      //           'Remaining: ${(stateBloc.savingPlans[index].targetMoney - stateBloc.savingPlans[index].checkout.fold(0.0, (previous, current) => previous + current.money)).toString().formatMoney()} '),
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                    // Text('${stateBloc.savingPlans[index].checkout.fold(0.0, (previous, current) => previous + current.money)}')
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                        ),
                                      ),
                                      // IconButton(
                                      //   onPressed: () {
                                      //     print(stateBloc
                                      //         .savingPlans[index].notification);
                                      //   },
                                      //   icon: Icon(
                                      //     stateBloc.savingPlans[index]
                                      //             .notification
                                      //         ? Icons.notifications_active
                                      //         : Icons.notifications_none,
                                      //     size: 20,
                                      //     color: stateBloc.savingPlans[index]
                                      //             .notification
                                      //         ? Colors.green
                                      //         : Colors.red,
                                      //   ),
                                      // ),
                                      // IconButton(
                                      //   onPressed: () {
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             DetailSavingScreen(
                                      //           data: stateBloc
                                      //               .savingPlans[index],
                                      //         ),
                                      //       ),
                                      //     );
                                      //   },
                                      //   icon: Icon(
                                      //     Icons.remove_red_eye,
                                      //     size: 20,
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // IconButton(
                                      //   onPressed: () {},
                                      //   icon: Icon(
                                      //     Icons.delete,
                                      //     size: 20,
                                      //   ),
                                      // ),
                                      // IconButton(
                                      //   onPressed: () {},
                                      //   icon: Icon(
                                      //     Icons.edit,
                                      //     size: 20,
                                      //   ),
                                      // ),
                                      IconButton(
                                        onPressed: () {
                                          print(stateBloc
                                              .savingPlans[index].notification);
                                        },
                                        icon: Icon(
                                          stateBloc.savingPlans[index]
                                                  .notification
                                              ? Icons.notifications_active
                                              : Icons.notifications_none,
                                          size: 20,
                                          color: stateBloc.savingPlans[index]
                                                  .notification
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailSavingScreen(
                                                index: index,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          size: 20,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                            // child: Text(stateBloc.savingPlans[index].name),
                            );
                      },
                    ),
                  )
                ],
              ),
            ),
            stateBloc.loading
                ? Container(
                    width: context.dynamicHeight(1),
                    height: context.dynamicHeight(1),
                    color: Colors.transparent,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SizedBox(),
          ],
        );
      }),
    );
  }
}
