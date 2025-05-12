import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/transaction_bulk_model.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:equatable/equatable.dart';

class TransactionState extends Equatable {
  final bool loading;
  final List<TransactionDailyModel> daily;
  final List<TransactionBulkModel> monthly;
  final AuthStatus status;
  final Object? message;
  const TransactionState._({
    this.loading = false,
    this.daily = const [],
    this.monthly = const [],
    this.status = AuthStatus.authenticated,
    this.message,
  });
  const TransactionState({
    this.loading = false,
    this.daily = const [],
    this.monthly = const [],
    this.status = AuthStatus.authenticated,
    this.message,
  });

  const TransactionState.defaultVal() : this._();
  const TransactionState.sessionLost() : this._(status: AuthStatus.guest);
  const TransactionState.setLoading(
    bool loading,
    List<TransactionDailyModel> daily,
    List<TransactionBulkModel> monthly,
  ) : this._(
          daily: daily,
          loading: loading,
          monthly: monthly,
        );
  const TransactionState.finishLoad(
    List<TransactionDailyModel> daily,
    List<TransactionBulkModel> monthly,
  ) : this._(
          // categories: categories,
          daily: daily,
          loading: false,
          monthly: monthly,
        );
  const TransactionState.error(
    List<TransactionDailyModel> daily,
    List<TransactionBulkModel> monthly,
    Object? message,
  ) : this._(
          // categories: categories,
          daily: daily,
          loading: false,
          monthly: monthly,
          message: message,
        );

  @override
  List<Object?> get props => [loading, daily, monthly, status];
}

class TransactionStateLoading extends TransactionState {
  const TransactionStateLoading({
    required List<TransactionDailyModel> newDaily,
    required List<TransactionBulkModel> newMonthly,
  }) : super(
          daily: newDaily,
          monthly: newMonthly,
          loading: true,
        );
  @override
  List<Object?> get props =>
      [super.loading, super.daily, super.monthly, super.status];
}

class TransactionStateFinishLoad extends TransactionState {
  const TransactionStateFinishLoad({
    required List<TransactionDailyModel> newDaily,
    required List<TransactionBulkModel> newMonthly,
  }) : super(
          daily: newDaily,
          monthly: newMonthly,
        );
  @override
  List<Object?> get props =>
      [super.loading, super.daily, super.monthly, super.status];
}
