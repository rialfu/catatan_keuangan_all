import 'package:intl/intl.dart';

extension DoubleCustom on double {
  String toFormatMoneyForm() {
    double fraction = this - (this).truncate();
    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: fraction == 0 ? 0 : 2,
    );
    return formatter.format(this);
  }
}
