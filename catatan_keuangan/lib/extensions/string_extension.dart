import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:intl/intl.dart';

extension StringCustom on String {
  String formatMoney() {
    final NumberFormat usCurrency = NumberFormat("#,##0.00", "en_US");
    // final NumberFormat usCurrency = NumberFormat('#,##0', 'en_US');
    double val = double.tryParse(this) ?? 0;
    return usCurrency.format(val);
  }

  double moneyToDouble() {
    if (this == '') return 0;
    List<String> data = this.split('.');
    String newString = data[0].replaceAll(',', '');
    return double.tryParse(newString + '.' + data[1]) ?? 0;
  }

  String formatDateddMMyyyy() {
    DateTime date = DateTime.parse(this);
    return date.ddMMyyyy();
  }

  String formatDateddM3yyyy() {
    DateTime date = DateTime.parse(this);
    return date.ddM3yyyy();
  }

  String formatDateMMyyyy() {
    // List<String> split_str = this.split('-');
    DateTime date = DateTime.parse(this);
    return date.MMyyyy();
  }

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
