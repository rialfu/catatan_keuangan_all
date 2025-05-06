import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:equatable/equatable.dart';

class SavingPlanState extends Equatable {
  final bool loading;
  final List<SavingPlanModel> savingPlans;
  final AuthStatus status;
  final Object? message;
  const SavingPlanState._({
    this.savingPlans = const [],
    this.loading = false,
    this.status = AuthStatus.authenticated,
    this.message,
    // this.
  });
  const SavingPlanState({
    this.savingPlans = const [],
    this.loading = false,
    this.status = AuthStatus.authenticated,
    this.message,
    // this.
  });

  const SavingPlanState.defaultVal() : this._();
  const SavingPlanState.sessionLost() : this._(status: AuthStatus.guest);

  const SavingPlanState.finishLoad(
    List<SavingPlanModel> data,
  ) : this._(
          savingPlans: data,
          loading: false,
        );
  const SavingPlanState.error(
    List<SavingPlanModel> categories,
    Object? message,
  ) : this._(
          savingPlans: categories,
          loading: false,
          message: message,
        );

  @override
  List<Object?> get props => [loading, savingPlans, message];
}

class SavingPlanStateLoad extends SavingPlanState {
  const SavingPlanStateLoad({
    required List<SavingPlanModel> data,
  }) : super(savingPlans: data, loading: true);

  @override
  List<Object?> get props => [super.loading, super.savingPlans, super.status];
}

class SavingPlanStateFinishLoad extends SavingPlanState {
  const SavingPlanStateFinishLoad({
    required List<SavingPlanModel> data,
  }) : super(savingPlans: data);
  @override
  List<Object?> get props => [super.loading, super.savingPlans, super.status];
}
