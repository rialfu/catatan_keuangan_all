import 'package:catatan_keuangan/components/dropdown_component.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
        builder: (context, state) {
      return Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 2,
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
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
                        ),
                      ),
                      onPressed: () async {
                        if (tranBloc.state.loading == false) {
                          tranBloc.add(TransactionGetMonthlyData(year));
                        }
                      },
                      child: Text("Search"),
                    ),
                  ),
                  Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(width: 1),
                      top: BorderSide(
                        width: index == 0 ? 1 : 0,
                      ),
                    )),
                    // color: Colors.red.shade400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (state.monthly[index].name + '-01')
                              .formatDateMMyyyy(),
                          style: TextStyle(fontSize: 18),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              state.monthly[index].totalIn
                                  .toString()
                                  .formatMoney(),
                              style:
                                  TextStyle(color: Colors.green, fontSize: 15),
                            ),
                            Text(
                              state.monthly[index].totalOut
                                  .toString()
                                  .formatMoney(),
                              style: TextStyle(color: Colors.red, fontSize: 15),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                  // if (index == 0) {
                  //   return Column(
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Expanded(
                  //               child: Center(
                  //                   child: Text(
                  //             'Date',
                  //             style: TextStyle(fontSize: 18),
                  //           ))),
                  //           Expanded(
                  //               child: Align(
                  //             alignment: Alignment.center,
                  //             child: Wrap(
                  //               children: [
                  //                 Icon(
                  //                   CupertinoIcons.chevron_up,
                  //                   // Icons.arrow_drop_down,
                  //                   size: 25,
                  //                   color: Colors.red,
                  //                 ),
                  //                 SizedBox(
                  //                   width: 5,
                  //                 ),
                  //                 Text(
                  //                   'Out',
                  //                   style: TextStyle(fontSize: 18),
                  //                 ),
                  //               ],
                  //             ),
                  //           )),
                  //           Expanded(
                  //             child: Align(
                  //               alignment: Alignment.center,
                  //               child: Wrap(
                  //                 children: [
                  //                   Icon(
                  //                     CupertinoIcons.chevron_down,
                  //                     // Icons.arrow_drop_down,
                  //                     size: 25,
                  //                     color: Colors.green,
                  //                   ),
                  //                   SizedBox(
                  //                     width: 5,
                  //                   ),
                  //                   Text(
                  //                     'Out',
                  //                     style: TextStyle(fontSize: 18),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //         children: [
                  //           Expanded(
                  //               child: Center(
                  //                   child: Text(state.monthly[index].name))),
                  //           Expanded(
                  //             child: Align(
                  //               alignment: Alignment.centerRight,
                  //               child: Text(state.monthly[index].totalOut
                  //                   .toString()
                  //                   .formatMoney()),
                  //             ),
                  //           ),
                  //           Expanded(
                  //             child: Align(
                  //               alignment: Alignment.centerRight,
                  //               child: Text(state.monthly[index].totalIn
                  //                   .toString()
                  //                   .formatMoney()),
                  //             ),
                  //           )
                  //         ],
                  //       )
                  //     ],
                  //   );
                  // }
                  // return Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     Expanded(
                  //         child:
                  //             Center(child: Text(state.monthly[index].name))),
                  //     Expanded(
                  //       child: Align(
                  //         alignment: Alignment.centerRight,
                  //         child: Text(state.monthly[index].totalOut
                  //             .toString()
                  //             .formatMoney()),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Align(
                  //         alignment: Alignment.centerRight,
                  //         child: Text(state.monthly[index].totalIn
                  //             .toString()
                  //             .formatMoney()),
                  //       ),
                  //     )
                  //   ],
                  // );
                },
                itemCount: state.monthly.length,
              ),
            )
          ],
        ),
      );
    });
  }
}
