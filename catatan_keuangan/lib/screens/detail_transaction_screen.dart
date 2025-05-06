import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/extensions/string_extension.dart';
import 'package:flutter/material.dart';

class DetailTransactionScreen extends StatefulWidget {
  final TransactionDailyModel data;
  const DetailTransactionScreen({super.key, required this.data});

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          "Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name :"),
            Text(widget.data.name),
            SizedBox(
              height: 10,
            ),
            Text("Detail :"),
            Text(widget.data.detail ?? ''),
            SizedBox(
              height: 10,
            ),
            Text("Type :"),
            Text(widget.data.debitCredit == 'debit' ? 'In' : 'Out'),
            SizedBox(
              height: 10,
            ),
            Text("Money :"),
            Text(widget.data.harga.formatMoney()),
            SizedBox(
              height: 10,
            ),
            Text("Category :"),
            Text(widget.data.category ?? ''),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
