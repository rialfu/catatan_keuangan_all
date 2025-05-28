import 'package:intl/intl.dart';

extension CustomDateTime on DateTime {
  String yyyymmdd() {
    return "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  String ddMMyyyy() {
    return DateFormat('dd MMMM yyyy').format(this);
  }

  String ddM3yyyy() {
    String dateString = DateFormat('dd MMMM yyyy').format(this);
    List<String> dateSplit = dateString.split(' ');
    String nameMonth = '';
    if (dateSplit[1].toLowerCase() == 'september') {
      nameMonth = dateSplit[1].substring(0, 4);
    } else {
      nameMonth = dateSplit[1].substring(0, 3);
    }
    return '${dateSplit[0]} $nameMonth ${dateSplit[2]}';
  }

  String formatMMyyyy() {
    return DateFormat('MMMM yyyy').format(this);
  }

  String formatMM3chyyyy() {
    List<String> split_str = DateFormat('MMMM yyyy').format(this).split(' ');
    if (split_str[0].toLowerCase().startsWith('sept')) {
      return '${split_str[0].substring(0, 4)} ${split_str[1]}';
    }
    return '${split_str[0].substring(0, 3)} ${split_str[1]}';
  }

  String getNameWeek() {
    return DateFormat.EEEE().format(this);
  }

  String getNameofMonth() {
    String nameOfMonth = DateFormat("MMMM").format(this);
    if (nameOfMonth.toLowerCase().startsWith('sept')) {
      return nameOfMonth.substring(0, 4);
    } else {
      return nameOfMonth.substring(0, 3);
    }
  }
}
