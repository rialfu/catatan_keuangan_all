class TransactionBulkModel {
  final String name;
  final double totalIn;
  final double totalOut;
  // final String
  TransactionBulkModel(
      {required this.name, this.totalIn = 0, this.totalOut = 0});

  TransactionBulkModel addIn(double data) {
    return TransactionBulkModel(name: name, totalIn: data, totalOut: totalOut);
  }

  TransactionBulkModel addOut(double data) {
    return TransactionBulkModel(name: name, totalIn: totalIn, totalOut: data);
  }
}
