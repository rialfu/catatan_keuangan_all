import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionStarted extends TransactionEvent {}

class TransactionDailyRequested extends TransactionEvent {
  final String date;

  const TransactionDailyRequested(this.date);

  @override
  List<Object?> get props => [date];
}

class TransactionSaveRequested extends TransactionEvent {
  final TransactionDailyModel data;
  final String? date;
  const TransactionSaveRequested(this.data, {this.date});
  @override
  List<Object?> get props => [data, date];
}

class TransactionUpdateRequested extends TransactionEvent {
  final TransactionDailyModel data;
  final String? date;
  const TransactionUpdateRequested(this.data, {this.date});

  @override
  List<Object?> get props => [data];
}

class TransactionDeleteRequested extends TransactionEvent {
  final int id;
  const TransactionDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionCleanMessage extends TransactionEvent {
  // final TransactionDailyModel data;
  const TransactionCleanMessage();
  // @override
  // List<Object?> get props => [data];
}

class TransactionGetMonthlyData extends TransactionEvent {
  final String year;
  const TransactionGetMonthlyData(this.year);
  @override
  List<Object?> get props => [year];
}

class TransactionReset extends TransactionEvent {}
