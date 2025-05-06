import 'package:intl/intl.dart';

extension customDateTime on DateTime {
  String yyyymmdd() {
    return "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  String ddMMyyyy() {
    return DateFormat('dd MMMM yyyy').format(this);
  }

  String ddM3yyyy() {
    String dateString = DateFormat('dd MMMM yyyy').format(this);
    List<String> date_split = dateString.split(' ');
    String name_month = '';
    if (date_split[1].toLowerCase() == 'september') {
      name_month = date_split[1].substring(0, 4);
    } else {
      name_month = date_split[1].substring(0, 3);
    }
    return '${date_split[0]} ${name_month} ${date_split[2]}';
  }

  String MMyyyy() {
    return DateFormat('MMMM yyyy').format(this);
  }
  // String ddMMMyyyy(){
  //   // return DateFormat('dd MMMM yyyy').format(this)
  // }
}
