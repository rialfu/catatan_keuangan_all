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

class SavingPlanUpdateRequested extends SavingPlanEvent {
  final SavingPlanModel data;
  const SavingPlanUpdateRequested(this.data);
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
