import 'package:auto_size_text/auto_size_text.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/extensions/context_entension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/screens/modify_transacation_screen.dart';
import 'package:catatan_keuangan/template/template_header1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late final TransactionBloc tranBloc;
  // int _tapCount = 0;
  // Timer? _tapTimer;
  bool isLoad = false;
  @override
  void initState() {
    super.initState();
    tranBloc = context.read<TransactionBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, valueTrans) {
      double totalIn = valueTrans.daily.fold(
          0.0,
          (prev, curr) =>
              prev + (curr.debitCredit == 'debit' ? curr.harga : 0));
      double totalOut = valueTrans.daily.fold(
          0.0,
          (prev, curr) =>
              prev + (curr.debitCredit == 'credit' ? curr.harga : 0));
      Map<String, List<TransactionDailyModel>> data = {};
      for (int i = 0; i < valueTrans.daily.length; i++) {
        if (data.containsKey(valueTrans.daily[i].tanggal)) {
          data[valueTrans.daily[i].tanggal]!.add(valueTrans.daily[i]);
        } else {
          data[valueTrans.daily[i].tanggal] = [valueTrans.daily[i]];
        }
      }
      List<String> keys = data.keys.toList();
      keys.sort((a, b) => a.compareTo(b));

      double total = totalIn - totalOut;
      return Container(
        color: Colors.grey[400],
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  templateHeader1(
                    'Income',
                    totalIn.toString().formatMoney(),
                  ),
                  templateHeader1(
                    'Expense',
                    totalOut.toString().formatMoney(),
                  ),
                  templateHeader1(
                    'Total',
                    total.toString().formatMoney(),
                  ),
                ],
              ),
            ),
            if (valueTrans.daily.isEmpty)
              Expanded(
                child: Center(
                  child: Text("Data is Empty"),
                ),
              ),
            if (data.isNotEmpty)
              SizedBox(
                height: 10,
              ),
            if (data.isNotEmpty)
              Expanded(
                  child: ListView.separated(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  List<TransactionDailyModel> datas = data[keys[index]]!;
                  return Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  keys[index].split('-')[2],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      maxLines: 1,
                                      keys[index].formatMonthDotYear(),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 7),
                                      color: Colors.grey[700],
                                      child: AutoSizeText(
                                        maxLines: 1,
                                        keys[index].getNameOfWeek(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: AutoSizeText(
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  datas
                                      .fold(
                                          0.0,
                                          (p, c) =>
                                              p +
                                              (c.debitCredit == 'debit'
                                                  ? c.harga
                                                  : 0))
                                      .toString()
                                      .formatMoney(),
                                  style: TextStyle(
                                    color: Colors.green,
                                    // fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: AutoSizeText(
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  datas
                                      // data[keys[index]]!
                                      .fold(
                                          0.0,
                                          (p, c) =>
                                              p +
                                              (c.debitCredit == 'credit'
                                                  ? c.harga
                                                  : 0))
                                      .toString()
                                      .formatMoney(),
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...datas.map(
                          (e) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifyTransactionScreen(
                                    data: e,
                                    date: e.tanggal,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              // color: Colors.red,
                              // decoration: BoxDecoration(
                              //   border: Border(bottom: BorderSide(width: 1)),
                              // ),
                              width: context.dynamicWidth(1),
                              padding: EdgeInsets.symmetric(
                                // vertical: 5,
                                horizontal: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      e.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      e.hargaWithFormatMoney(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: e.debitCredit == 'debit'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      onPressed: () {
                                        var bloc =
                                            context.read<TransactionBloc>();
                                        if (bloc.state
                                            is TransactionStateLoading) {
                                          return;
                                        }

                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible:
                                              false, // user must tap button!
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirmation'),
                                              content:
                                                  const SingleChildScrollView(
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
                                                    bloc.add(
                                                        TransactionDeleteRequested(
                                                            e.id));
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
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 10,
                  );
                },
              ))
          ],
        ),
      );
    });
  }
}
