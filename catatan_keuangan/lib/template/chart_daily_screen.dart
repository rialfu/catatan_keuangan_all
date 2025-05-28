import 'dart:async';

import 'package:catatan_keuangan/core/bloc/transaction/transaction_bloc.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/extensions/double_extension.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}

class ChartDailyScreen extends StatefulWidget {
  const ChartDailyScreen({super.key});

  @override
  State<ChartDailyScreen> createState() => _ChartDailyScreenState();
}

class _ChartDailyScreenState extends State<ChartDailyScreen> {
  List<_ChartData> dataChart = [];
  Map<String, Map<String, dynamic>> allData = {};
  Set<String> selected = {};
  final TooltipBehavior tooltip = TooltipBehavior(
    enable: true,
    builder: (data, point, series, pointIndex, seriesIndex) {
      return Container(
        padding: EdgeInsets.all(2.0),
        child: Text(
          '${data.x}:${data.y.toString().formatMoney()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      );
    },
  );
  late StreamSubscription stream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var blocTrans = context.read<TransactionBloc>();
    stream = blocTrans.stream.listen((event) {
      loadData(event.daily);
    });
    loadData(blocTrans.state.daily);
  }

  @override
  void dispose() {
    stream.cancel();

    // TODO: implement dispose
    super.dispose();
  }

  void loadData(List<TransactionDailyModel> data) {
    Map<String, Map<String, dynamic>> dataForChart = {};
    Set<String> cacheSelected = {};
    // List<TransactionDailyModel> transData = blocTrans.state.daily;
    // Set<String> selected = Set.from([]);
    for (int i = 0; i < data.length; i++) {
      String ie = data[i].debitCredit == 'debit' ? '1' : '2';
      String cat = data[i].categoryId.toString();
      if (dataForChart.containsKey('$ie|$cat')) {
        dataForChart['$ie|$cat']!['jumlah'] =
            dataForChart['$ie|$cat']!['jumlah']! + data[i].harga;
      } else {
        dataForChart['$ie|$cat'] = {
          'keterangan':
              '${(ie == '1' ? 'Income' : 'Expense')} ${data[i].category}',
          'jumlah': data[i].harga
        };
        // if (i != 1)
        cacheSelected.add('$ie|$cat');
      }
    }
    // print(dataForChart);
    List<String> keys = dataForChart.keys.toList();
    List<_ChartData> cache = [];
    for (int i = 0; i < keys.length; i++) {
      if (dataForChart.containsKey(keys[i])) {
        Map<String, dynamic> cacheData = dataForChart[keys[i]]!;
        cache.add(_ChartData(cacheData['keterangan'], cacheData['jumlah']));
      }
    }
    setState(() {
      selected = cacheSelected;
      dataChart = cache;
      allData = dataForChart;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> keys = allData.keys.toList();
    if (keys.isEmpty) {
      return Container(
        color: Colors.grey[400],
        child: Center(
          child: Text('Data is Empty'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Filter",
            style: TextStyle(
              fontSize: 17,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(allData[keys[index]]!['keterangan']),
                    Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.pink,
                      value: selected.contains(keys[index]),
                      onChanged: (bool? value) {
                        List<_ChartData> cache = [];
                        var cacheSelected = selected;
                        if (value == true) {
                          // selected.add(keys[index]);
                          cacheSelected.add(keys[index]);
                        } else {
                          // selected.remove(keys[index]);
                          cacheSelected.remove(keys[index]);
                        }
                        // allData.keys.toList();
                        for (int i = 0; i < keys.length; i++) {
                          if (selected.contains(keys[i])) {
                            // print(allData[keys[index]]);
                            cache.add(_ChartData(
                              allData[keys[i]]!['keterangan'],
                              allData[keys[i]]!['jumlah'],
                            ));
                          }
                        }
                        setState(() {
                          dataChart = cache;
                          selected = cacheSelected;
                          // first = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
            itemCount: keys.length,
          ),
        ),
        Expanded(
          flex: 3,
          child:
              // Container()
              // SfCartesianChart(
              //   primaryXAxis: CategoryAxis(),
              //   // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
              //   tooltipBehavior: tooltip,
              //   series: <CartesianSeries<_ChartData, String>>[
              //     ColumnSeries<_ChartData, String>(
              //       dataSource: dataChart,
              //       xValueMapper: (_ChartData data, _) => data.x,
              //       yValueMapper: (_ChartData data, _) => data.y,
              //       name: 'Gold',
              //       color: const Color.fromRGBO(8, 142, 255, 1),
              //       // Optional: Add data labels
              //       dataLabelSettings: const DataLabelSettings(isVisible: true),
              //     )
              //   ],
              // ),
              SfCircularChart(
            // borderWidth: 30,

            tooltipBehavior: tooltip,
            series: <CircularSeries<_ChartData, String>>[
              DoughnutSeries<_ChartData, String>(
                  dataSource: dataChart,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'Gold',
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition
                        .outside, // Labels outside the slices
                    // connectorLineSettings: ConnectorLineSettings(type: ConnectorLineType.curve), // Curved lines for labels
                    // You can also format data labels directly if needed, e.g.:
                    // builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                    //   final ExpenseData expense = data;
                    //   final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
                    //   return Text(currencyFormatter.format(expense.amount));
                    // }
                    builder: (data, point, series, pointIndex, seriesIndex) {
                      if (data is _ChartData) {
                        // _ChartData d = data as _ChartData;
                        return Text(
                          '${data.x}:${data.y.toFormatMoneyForm()}',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        );
                      }
                      // print(data);
                      // print('jal');
                      return Text(
                          '${(data.y as double).toString().formatMoney()}');
                    },
                  ))
            ],
          ),
        ),
        Expanded(flex: 1, child: Container())
      ],
    );
  }
}
