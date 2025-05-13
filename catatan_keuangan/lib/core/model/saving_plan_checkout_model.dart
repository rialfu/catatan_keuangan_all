class SavingPlanCheckoutModel {
  int id;
  double money;
  String dateCheckout;
  SavingPlanCheckoutModel({
    required this.id,
    required this.money,
    required this.dateCheckout,
  });
  Map<String, dynamic> toJsonSave() {
    return {
      'money': money,
      'date_checkout': dateCheckout,
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'money': money,
      'date_checkout': dateCheckout,
    };
  }

  factory SavingPlanCheckoutModel.fromJson(Map<String, dynamic> json) {
    int id = json['id'] as int;
    double money = 0;
    // String dateCheckout = '';
    String dateCheckout = json['date_checkout'] as String;
    if (json.containsKey('money')) {
      if (json['money'] is String) {
        money = double.tryParse(json['money'] as String) ?? 0;
      } else if (json['money'] is double) {
        money = json['money'] as double;
      }
    }
    return SavingPlanCheckoutModel(
      id: id,
      money: money,
      dateCheckout: dateCheckout,
    );
  }
}
