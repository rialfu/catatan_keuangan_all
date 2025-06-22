import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_bloc.dart';
import 'package:catatan_keuangan/core/bloc/auth/auth_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_bloc.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_state.dart';
import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/screens/modify_saving_plan_checkout.dart';
import 'package:catatan_keuangan/screens/modify_saving_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailSavingScreen extends StatefulWidget {
  final int index;
  final String id;
  const DetailSavingScreen({required this.index, required this.id, super.key});

  @override
  State<DetailSavingScreen> createState() => _DetailSavingScreenState();
}

class _DetailSavingScreenState extends State<DetailSavingScreen> {
  Widget formattingText(String row1, String row2) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              row1,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AutoSizeText(
              ': $row2',
              maxLines: 1,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  String formattingEnd(String? data) {
    if (data == null) return '';
    int? numbering = int.tryParse(data);
    if (numbering != null) {
      if (!(numbering >= 1 && numbering <= 31)) {
        return '';
      }

      if (numbering >= 11 && numbering <= 13) {
        return '${numbering}th';
      }

      switch (numbering % 10) {
        case 1:
          return '${numbering}st';
        case 2:
          return '${numbering}nd';
        case 3:
          return '${numbering}rd';
        default:
          return '${numbering}th';
      }
    }
    return data;
  }

  Future<void> _showMyDialog() async {
    // debugPrintStack();
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
                var authBloc = context.read<AuthBloc>();
                authBloc.add(LogoutRequested());
              },
            ),
          ],
        );
      },
    );
  }

  bool isLoad = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Detail Saving Plan",
        ),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      body: BlocListener<SavingPlanBloc, SavingPlanState>(
        listener: (context, state) async {
          if (state.status == AuthStatus.guest) {
            _showMyDialog();
            return;
          }
          if (state.loading == false) {
            setState(() {
              isLoad = false;
            });
          }
          if (state.message != null) {
            // print(state.message);
            List message = [];
            if (state.message is List) {
              message.addAll(state.message as List);
            } else {
              message.add(state.message);
            }
            return showDialog<void>(
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
                        var bloc = context.read<SavingPlanBloc>();
                        Navigator.of(context).pop();
                        bloc.add(SavingPlanCleanMessage());
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: BlocBuilder<SavingPlanBloc, SavingPlanState>(
            builder: (context, state) {
          SavingPlanModel data = state.savingPlans[widget.index];
          if (data.id != widget.id) {
            data = state.savingPlans.firstWhere(
              (e) => e.id == widget.id,
              orElse: () => SavingPlanModel(
                id: '',
                name: '',
                typeReminder: '',
                dateReminder: '',
                targetDate: '',
                targetMoney: 0,
                notification: false,
              ),
            );
          }
          return Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    formattingText(
                        'Name', state.savingPlans[widget.index].name),
                    formattingText(
                      'Reminder',
                      '${state.savingPlans[widget.index].typeReminder} ${formattingEnd(state.savingPlans[widget.index].dateReminder)}',
                    ),
                    formattingText(
                      'Target Date',
                      state.savingPlans[widget.index].targetDate
                          .formatDateddMMyyyy(),
                    ),
                    formattingText(
                      'Saving Goal',
                      state.savingPlans[widget.index].targetMoney
                          .toString()
                          .formatMoney(),
                    ),
                    formattingText(
                      'Remaining',
                      (state.savingPlans[widget.index].remain())
                          .toString()
                          .formatMoney(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            var bloc = context.read<SavingPlanBloc>();
                            bloc.add(SavingPlanCheckoutRequested(data.id));
                          },
                          child: Text("Refresh"),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModifySavingPlanScreen(
                                  data: data,
                                ),
                              ),
                            );
                          },
                          child: Text("Edit Info"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModifySavingPlanCheckout(
                                  idSavingPlan: data.id,
                                ),
                              ),
                            );
                          },
                          child: Text("Store saving"),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            state.savingPlans[widget.index].checkout.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.only(left: 12),
                            // color: Colors.red,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 1),
                                top: BorderSide(width: index == 0 ? 1 : 0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        maxLines: 1,
                                        'Date :${state.savingPlans[widget.index].checkout[index].dateCheckout.formatDateddM3yyyy()}',
                                      ),
                                      AutoSizeText(
                                        maxLines: 1,
                                        'Store money :${state.savingPlans[widget.index].checkout[index].money.toString().formatMoney()}',
                                      )
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    var bloc = context.read<SavingPlanBloc>();
                                    if (bloc.state.loading || isLoad) {
                                      return;
                                    }

                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const SingleChildScrollView(
                                            child: ListBody(
                                              children: <Widget>[
                                                Text(
                                                  'Are You Sure want delete?',
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Ok'),
                                              onPressed: () {
                                                if (bloc.state.loading ||
                                                    isLoad) {
                                                  Navigator.of(context).pop();
                                                  return;
                                                }
                                                var savingPlan = state
                                                    .savingPlans[widget.index];
                                                var idSavingPlan =
                                                    savingPlan.id;
                                                var checkout =
                                                    savingPlan.checkout[index];

                                                var id = checkout.id;
                                                bloc.add(
                                                    SavingPlanCheckoutDeleteRequested(
                                                  id,
                                                  idSavingPlan,
                                                ));
                                                setState(() {
                                                  isLoad = true;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // bloc.add(SavingPlanCheckoutDeleteRequested(
                                    //   id,
                                    //   idSavingPlan,
                                    // ));
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              if (isLoad || state.loading)
                Container(
                  width: context.dynamicHeight(1),
                  height: context.dynamicHeight(1),
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
