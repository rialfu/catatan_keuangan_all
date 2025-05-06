import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/components/dropdown_component.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/screens/detail_transaction_screen.dart';
import 'package:catatan_keuangan/screens/modify_transacation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  // DateTime date = DateTime.now();

  String year = DateTime.now().year.toString();
  String month = (DateTime.now().month).toString().padLeft(2, '0');
  // late final TransactionBloc tranBloc;

  Widget datable(List<TransactionDailyModel> data) {
    if (data.isNotEmpty) {
      return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: data[index].debitCredit == 'debit'
                ? Colors.green.shade200
                : Colors.red.shade200,
            child: Row(
              // mainAxisAlignment: ,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data[index].tanggal.formatDateddM3yyyy(),
                        style: TextStyle(color: Colors.black45, fontSize: 17),
                      ),
                      Text(
                        data[index].category ?? 'Another',
                        style: TextStyle(color: Colors.black45, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          data[index].harga.formatMoney(),
                          maxLines: 1,
                          style: TextStyle(color: Colors.black45, fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailTransactionScreen(
                                        data: data[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.remove_red_eye,
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                // padding: EdgeInsets.all(0),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ModifyTransactionScreen(
                                        data: data[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog<void>(
                                    context: context, // user must tap button!
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Alert"),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: [
                                              Text("Do you want delete?")
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              tranBloc.add(
                                                  TransactionDeleteRequested(
                                                      data[index].id));
                                            },
                                            child: Text("Yes"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          // Column(
          //   children: [
          //     Row(children: [Text(data[index].category ??''), Text(data[index].harga.formatMoney())],),
          //     Row(children: [Text(data[index].name ??''), Text(data[index].harga.formatMoney())],),
          //   ],
          // );
        },
      );
    }
    return Center(
      child: Text("Empty"),
    );
  }

  late final TransactionBloc tranBloc;
  @override
  void initState() {
    super.initState();
    tranBloc = context.read<TransactionBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
      return BlocListener<TransactionBloc, TransactionState>(
        listener: (context, stateB) async {
          if (stateB.message != null) {
            List message = [];
            if (stateB.message is List) {
              message.addAll(stateB.message as List);
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
                        Navigator.of(context).pop();
                        tranBloc.add(TransactionCleanMessage());
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropDownComponent(
                      callback: (String? val) {
                        setState(() {
                          if (val != null) {
                            setState(() {
                              year = val;
                            });
                          }
                        });
                      },
                      setValue: year,
                      listData: List.generate(
                        100,
                        (int index) => {
                          'value': (index + 2000).toString(),
                          'name': (index + 2000).toString()
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: DropDownComponent(
                      callback: (String? val) {
                        if (val != null) {
                          setState(() {
                            month = val;
                          });
                        }
                      },
                      setValue: month,
                      listData: List.generate(
                        12,
                        (int index) => {
                          'value': (index + 1).toString().padLeft(2, '0'),
                          'name': (index + 1).toString().padLeft(2, '0')
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        if (state.loading == false) {
                          var bloc = context.read<TransactionBloc>();
                          bloc.add(
                              TransactionDailyRequested('$year-$month-01'));
                        }
                      },
                      child: AutoSizeText('Search'),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // <-- Radius
                          ),
                        ),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModifyTransactionScreen(),
                            ),
                          );
                        },
                        child: AutoSizeText("Add"),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 30,
                      ),
                      Text(
                        state.daily
                            .fold(
                                0.0,
                                (p, c) =>
                                    p +
                                    (c.debitCredit == 'debit'
                                        ? double.tryParse(c.harga) ?? 0
                                        : 0))
                            .toString()
                            .formatMoney(),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_drop_up,
                        color: Colors.red,
                        size: 30,
                      ),
                      Text(
                        state.daily
                            .fold(
                                0.0,
                                (p, c) =>
                                    p +
                                    (c.debitCredit == 'credit'
                                        ? double.tryParse(c.harga) ?? 0
                                        : 0))
                            .toString()
                            .formatMoney(),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 8,
              child: datable(state.daily),
            )
          ],
        ),
      );
    });
  }
}
