class TransactionDailyModel {
  int id;
  String name;
  String? detail;
  String harga;
  String debitCredit;
  String tanggal;
  String? category;
  int categoryId;
  // String kategori2;

  TransactionDailyModel({
    required this.id,
    required this.name,
    this.detail,
    required this.harga,
    required this.debitCredit,
    required this.tanggal,
    this.category,
    required this.categoryId,
    // this.kategori2 = 'primer',
  });
  TransactionDailyModel addId(int id) {
    return TransactionDailyModel(
      id: id,
      name: name,
      harga: harga,
      debitCredit: debitCredit,
      tanggal: tanggal,
      categoryId: categoryId,
    );
  }

  factory TransactionDailyModel.fromJson(Map<String, dynamic> json) {
    return TransactionDailyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String?,
      harga: json['harga'] as String,
      debitCredit: json['debcre'] as String,
      tanggal: json['tanggal_transaksi'] as String,
      category: json['category'] as String,
      categoryId: json['category_id'] as int,
      // kategori2: json['kategori2'] as String,
    );
  }
  Map<String, dynamic> toJsonSave() {
    return {
      'name': name,
      'detail': detail,
      'harga': double.tryParse(harga) ?? 0,
      'category': categoryId,
      'debcre': debitCredit,
      'tanggal': tanggal,
      'tanggal_transaksi': tanggal,
      // 'email': email,
      // 'password': password,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'harga': double.tryParse(harga) ?? 0,
      'category': categoryId,
      'debcre': debitCredit,
      'tanggal_transaksi': tanggal,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail': detail,
      'harga': double.tryParse(harga) ?? 0,
      'category': categoryId,
      'category_name': category,
      'debcre': debitCredit,
      'tanggal_transaksi': tanggal,
    };
  }
}
