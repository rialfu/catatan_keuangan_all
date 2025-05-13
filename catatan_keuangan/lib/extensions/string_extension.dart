import 'package:catatan_keuangan/extensions/datetime_extension.dart';
import 'package:intl/intl.dart';

extension StringCustom on String {
  String formatMoney() {
    final NumberFormat usCurrency = NumberFormat("#,##0.00", "en_US");
    // final NumberFormat usCurrency = NumberFormat('#,##0', 'en_US');
    double val = double.tryParse(this) ?? 0;
    return usCurrency.format(val);
  }

  String fixStringMoney() {
    String value = this;
    int countDot = '.'.allMatches(this).length;
    var splitStr = value.split('.');

    if (splitStr.length > 2) {
      String main = splitStr[0].replaceAll(RegExp(r"\D"), "");
      value = '$main.';
      String fraction = '';
      for (int i = 1; i < splitStr.length; i++) {
        fraction = splitStr[i].replaceAll(RegExp(r"\D"), "");
        value = value + fraction;
      }
    }
    splitStr = value.split('.');
    if (splitStr.length == 2) {
      String main = splitStr[0].replaceAll(RegExp(r"\D"), "");

      String fraction = splitStr[1];
      if ((main + fraction).length > 22) {
        if (main.length > 20) {
          main = main.substring(0, 20);
        } else if (main.length == 20 && fraction.length > 2) {
          fraction = fraction.substring(0, 2);
        }
      }
      if (fraction.length > 2) {
        main = main + fraction[1];
        fraction = fraction.substring(1);
      }

      main = main.formatMoneyWithoutCommaAndSupportLargest();
      value = '$main.$fraction';
    } else {
      String main = splitStr[0].replaceAll(RegExp(r"\D"), "");
      if (main == '') {
        value = main;
      } else {
        if (main.length > 20) {
          main = main.substring(0, 20);
        }
        main = main.formatMoneyWithoutCommaAndSupportLargest();
        value = main + (countDot > 0 ? '.' : '');
      }
    }
    return value;
  }

  String formatMoneyWithoutCommaAndSupportLargest() {
    String formattedString = '';
    int counter = 0;
    for (int i = this.length - 1; i >= 0; i--) {
      formattedString = this[i] + formattedString;
      counter++;
      if (counter % 3 == 0 && i != 0) {
        formattedString = ',$formattedString';
        // formattedString = ',' + formattedString;
      }
    }
    return formattedString;
  }

  double moneyToDouble() {
    if (this == '') return 0;
    List<String> data = this.split('.');
    String newString = data[0].replaceAll(',', '');
    // newString + '.' + data[1]
    return double.tryParse('$newString.${data[1]}') ?? 0;
  }

  String stringDoubleToMoney() {
    if (this == '') return '';
    List<String> data = this.split('.');
    String newString = data[0].replaceAll(',', '');
    // newString + '.' + data[1]
    double value = double.tryParse('$newString.${data[1]}') ?? 0;
    final NumberFormat usCurrency = NumberFormat("#,##0.00", "en_US");
    return usCurrency.format(value);
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
    return date.formatMMyyyy();
  }

  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  String formatMonthDotYear() {
    List<String> data = this.split('-');
    return '${data[1]}.${data[0]}';
  }

  String getNameOfWeek() {
    try {
      return DateTime.parse(this).getNameWeek();
    } catch (err) {
      return '';
    }
  }
}
