import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:catatan_keuangan/template/templateHeader1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  String year = DateTime.now().year.toString();

  late final TransactionBloc tranBloc;
  @override
  void initState() {
    super.initState();
    tranBloc = context.read<TransactionBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, stateTrans) {
      double inc = stateTrans.monthly.fold(0.0, (p, c) => p + c.totalIn);
      double exp = stateTrans.monthly.fold(0.0, (p, c) => p + c.totalOut);
      double total = inc - exp;
      DateTime dt = DateTime.now();
      String now = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
      return Container(
        color: Colors.grey[400],
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  templateHeader1(
                    'Income',
                    inc.toString().formatMoney(),
                  ),
                  templateHeader1(
                    'Expense',
                    exp.toString().formatMoney(),
                  ),
                  templateHeader1(
                    'Total',
                    // ,
                    total.toString().formatMoney(),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: stateTrans.monthly
                      .map(
                        (e) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  // constraints: BoxConstraints(minWidth: ),
                                  color: e.name == now
                                      ? Colors.yellow[800]
                                      : Colors.grey[700],
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    DateTime.parse('${e.name}-01')
                                        .getNameofMonth(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  textAlign: TextAlign.end,
                                  e.totalIn.toString().formatMoney(),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  textAlign: TextAlign.end,
                                  e.totalIn.toString().formatMoney(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // Text(e.name),
                              // ,
                              // Text(e.totalOut.toString()),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      );
      // return Container(
      //   child: Column(
      //     children: [
      //       Expanded(
      //         flex: 1,
      //         child: Row(
      //           children: [
      //             Expanded(flex: 1, child: SizedBox()),
      //             Expanded(
      //               flex: 2,
      //               child: DropDownComponent(
      //                 callback: (String? val) {
      //                   setState(() {
      //                     if (val != null) {
      //                       setState(() {
      //                         year = val;
      //                       });
      //                     }
      //                   });
      //                 },
      //                 setValue: year,
      //                 listData: List.generate(
      //                   100,
      //                   (int index) => {
      //                     'value': (index + 2000).toString(),
      //                     'name': (index + 2000).toString()
      //                   },
      //                 ),
      //               ),
      //             ),
      //             Expanded(
      //               flex: 2,
      //               child: ElevatedButton(
      //                 style: ElevatedButton.styleFrom(
      //                   backgroundColor: Colors.red,
      //                   foregroundColor: Colors.white,
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(12), // <-- Radius
      //                   ),
      //                 ),
      //                 onPressed: () async {
      //                   if (tranBloc.state.loading == false) {
      //                     tranBloc.add(TransactionGetMonthlyData(year));
      //                   }
      //                 },
      //                 child: Text("Search"),
      //               ),
      //             ),
      //             Expanded(flex: 1, child: SizedBox()),
      //           ],
      //         ),
      //       ),
      //       Expanded(
      //         flex: 9,
      //         child: ListView.builder(
      //           itemBuilder: (context, index) {
      //             return Container(
      //               padding: EdgeInsets.all(10),
      //               decoration: BoxDecoration(
      //                   border: Border(
      //                 bottom: BorderSide(width: 1),
      //                 top: BorderSide(
      //                   width: index == 0 ? 1 : 0,
      //                 ),
      //               )),
      //               // color: Colors.red.shade400,
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Text(
      //                     (state.monthly[index].name + '-01')
      //                         .formatDateMMyyyy(),
      //                     style: TextStyle(fontSize: 18),
      //                   ),
      //                   Column(
      //                     crossAxisAlignment: CrossAxisAlignment.end,
      //                     children: [
      //                       Text(
      //                         state.monthly[index].totalIn
      //                             .toString()
      //                             .formatMoney(),
      //                         style:
      //                             TextStyle(color: Colors.green, fontSize: 15),
      //                       ),
      //                       Text(
      //                         state.monthly[index].totalOut
      //                             .toString()
      //                             .formatMoney(),
      //                         style: TextStyle(color: Colors.red, fontSize: 15),
      //                       )
      //                     ],
      //                   )
      //                 ],
      //               ),
      //             );
      //           },
      //           itemCount: state.monthly.length,
      //         ),
      //       )
      //     ],
      //   ),
      // );
    });
  }
}
