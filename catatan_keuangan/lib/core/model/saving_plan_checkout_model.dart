import 'package:flutter/services.dart';

class SavingPlanCheckoutModel {
  String id;
  double money;
  String dateCheckout;
  SavingPlanCheckoutModel({
    required this.id,
    required this.money,
    required this.dateCheckout,
  });
  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'money': money,
      'date_checkout': dateCheckout,
    };
  }

  factory SavingPlanCheckoutModel.fromJson(Map<String, dynamic> json) {
    String id = json['id'] as String;
    double money = 0;
    print('data: ${json['date_checkout']}');
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
