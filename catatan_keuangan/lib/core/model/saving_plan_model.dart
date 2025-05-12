import 'package:catatan_keuangan/core/model/saving_plan_checkout_model.dart';

class SavingPlanModel {
  String id;
  String name;
  String typeReminder;
  String? dateReminder;
  String targetDate;
  double targetMoney;
  bool notification;
  List<SavingPlanCheckoutModel> checkout;
  SavingPlanModel({
    required this.id,
    required this.name,
    required this.typeReminder,
    required this.dateReminder,
    required this.targetDate,
    required this.targetMoney,
    this.notification = false,
    this.checkout = const [],
  });
  factory SavingPlanModel.fromJson(Map<String, dynamic> json) {
    print(json);
    String id = json['id'] as String;
    String name = json['name'] as String;
    String typeReminder = json['type_reminder'] as String;
    String? dateReminder = json['date_reminder'] as String?;
    String targetDate = json['target_date'] as String;
    double targetMoney = 0;
    bool notification = false;
    if (json.containsKey('target_money')) {
      if (json['target_money'] is double) {
        targetMoney = json['target_money'] as double;
      } else if (json['target_money'] is String) {
        targetMoney = double.tryParse(json['target_money'] as String) ?? 0;
      }
    }
    if (json.containsKey('notification')) {
      print('notification:${json['notification'] == true} {}');
      if (json['notification'] is String) {
        notification = json['notification'] == '1' ? true : false;
      } else if (json['notification'] is bool) {
        notification = json['notification'] as bool;
      }
    }
    List<SavingPlanCheckoutModel> checkout = [];
    try {
      if (json.containsKey('checkout') && json['checkout'] is List) {
        // print(json['checkout']);
        checkout = (json['checkout'] as List).map(
          (e) {
            return SavingPlanCheckoutModel.fromJson(e);
          },
        ).toList();
        // SavingPlanCheckoutModel.fromJson(json['checkout']).to
      }
    } catch (err) {
      print(err);
    }
    return SavingPlanModel(
      id: id,
      name: name,
      typeReminder: typeReminder,
      dateReminder: dateReminder,
      targetDate: targetDate,
      targetMoney: targetMoney,
      notification: notification,
      checkout: checkout,
    );
  }
  SavingPlanModel update(
      {bool? newNotification, List<SavingPlanCheckoutModel>? newCheckout}) {
    return SavingPlanModel(
      id: id,
      name: name,
      typeReminder: typeReminder,
      dateReminder: dateReminder,
      targetDate: targetDate,
      targetMoney: targetMoney,
      checkout: newCheckout ?? checkout,
      notification: newNotification ?? notification,
    );
  }

  Map<String, dynamic> toJsonSave() {
    return {
      'name': name,
      'type_reminder': typeReminder,
      'date_reminder': dateReminder,
      'target_date': targetDate,
      'target_money': targetMoney,
      'notification': notification
    };
  }

  Map<String, dynamic> toJsonUpdate() {
    return {
      'id': id,
      'name': name,
      'type_reminder': typeReminder,
      'date_reminder': dateReminder,
      'target_date': targetDate,
      'target_money': targetMoney,
      'notification': notification
    };
  }
}
