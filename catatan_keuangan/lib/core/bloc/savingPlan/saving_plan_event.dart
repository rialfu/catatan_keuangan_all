import 'package:catatan_keuangan/core/model/saving_plan_checkout_model.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:equatable/equatable.dart';

abstract class SavingPlanEvent extends Equatable {
  const SavingPlanEvent();

  @override
  List<Object?> get props => [];
}

class SavingPlanStarted extends SavingPlanEvent {}

class SavingPlanRequested extends SavingPlanEvent {
  // final String date;
  const SavingPlanRequested();
}

class SavingPlanSaveRequested extends SavingPlanEvent {
  final SavingPlanModel data;
  const SavingPlanSaveRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class SavingPlanNotificationRequested extends SavingPlanEvent {
  final Map<String, dynamic> data;
  const SavingPlanNotificationRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class SavingPlanUpdateRequested extends SavingPlanEvent {
  final Map<String, dynamic> data;
  final SavingPlanModel forUpdate;
  const SavingPlanUpdateRequested(this.data, this.forUpdate);
  @override
  List<Object?> get props => [data];
}

class SavingPlanDeleteRequested extends SavingPlanEvent {
  final String id;
  const SavingPlanDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class SavingPlanCleanMessage extends SavingPlanEvent {
  // final SavingPlanDailyModel data;
  const SavingPlanCleanMessage();
  // @override
  // List<Object?> get props => [data];
}

class SavingPlanCheckoutRequested extends SavingPlanEvent {
  final String id;
  const SavingPlanCheckoutRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class SavingPlanCheckoutSavingRequested extends SavingPlanEvent {
  final SavingPlanCheckoutModel data;
  final String idSavingPlan;
  const SavingPlanCheckoutSavingRequested(this.data, this.idSavingPlan);
  @override
  List<Object?> get props => [data, idSavingPlan];
}

class SavingPlanCheckoutDeleteRequested extends SavingPlanEvent {
  final int id;
  final String idSavingPlan;
  const SavingPlanCheckoutDeleteRequested(this.id, this.idSavingPlan);
  @override
  List<Object?> get props => [id, idSavingPlan];
}
