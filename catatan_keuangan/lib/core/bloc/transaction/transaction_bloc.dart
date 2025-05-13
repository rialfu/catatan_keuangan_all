import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_event.dart';
import 'package:catatan_keuangan/core/bloc/transaction/transaction_state.dart';
import 'package:catatan_keuangan/core/model/transaction_bulk_model.dart';
import 'package:catatan_keuangan/core/model/transaction_daily_model.dart';
import 'package:catatan_keuangan/core/service/transaction_service.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  // final IAuthService authService;
  final AuthCacheManager authCacheManager;
  final TransactionService transactionService;

  TransactionBloc(this.authCacheManager, this.transactionService)
      : super(const TransactionState.defaultVal()) {
    on<TransactionStarted>((event, emit) async {
      emit(const TransactionState.defaultVal());
    });
    on<TransactionDailyRequested>(
      (event, emit) async {
        try {
          if (state.loading) return;
          emit(TransactionStateLoading(
            newDaily: state.daily,
            newMonthly: state.monthly,
          ));
          int start = DateTime.now().millisecondsSinceEpoch;
          var res =
              await transactionService.getTransaction(dateData: event.date);
          int finish = DateTime.now().millisecondsSinceEpoch;
          if (finish - start <= 1200) {
            await Future.delayed(
                Duration(milliseconds: 1000 - (finish - start)));
          }
          emit(TransactionStateFinishLoad(
            newDaily: res,
            newMonthly: state.monthly,
          ));
        } on CustomExceptionForPost catch (e) {
          print(e.cause);
          if (e.codeError == 429) {
            // emit(TransactionStateFinishLoad(
            //   newDaily: state.daily,
            //   newMonthly: state.monthly,
            // ));
            emit(TransactionState.error(
              state.daily,
              state.monthly,
              e.cause,
            ));
            return;
          }
        } catch (err) {
          print(err);
          if (err.toString().contains('unauthorized')) {
            emit(TransactionState.sessionLost());
            return;
          }

          emit(TransactionState.error(
            state.daily,
            state.monthly,
            err.toString(),
          ));
        }
      },
      transformer: droppable(),
    );
    // on<TransactionDailyRequested>((event, emit) async {
    //   try {
    //     if (state.loading) return;
    //     if (isLoad) return;
    //     isLoad = true;
    //     emit(TransactionStateLoading(
    //       newDaily: state.daily,
    //       newMonthly: state.monthly,
    //     ));
    //     var res = await transactionService.getTransaction(dateData: event.date);
    //     isLoad = false;
    //     emit(TransactionStateFinishLoad(
    //       newDaily: res,
    //       newMonthly: state.monthly,
    //     ));
    //   } on CustomExceptionForPost catch (e) {
    //     if (e.codeError == 429) {
    //       emit(TransactionState.error(
    //         state.daily,
    //         state.monthly,
    //         e.cause,
    //       ));
    //       // emit(TransactionStateFinishLoad(
    //       //   newDaily: state.daily,
    //       //   newMonthly: state.monthly,
    //       // ));
    //       isLoad = false;
    //       return;
    //     }
    //   } catch (err) {
    //     if (err.toString().contains('unauthorized')) {
    //       isLoad = false;
    //       emit(TransactionState.sessionLost());
    //       return;
    //     }
    //     isLoad = false;
    //     emit(TransactionState.error(
    //       state.daily,
    //       state.monthly,
    //       err.toString(),
    //     ));
    //   }

    //   // var res=
    // });
    on<TransactionSaveRequested>(
      (event, emit) async {
        try {
          emit(TransactionStateLoading(
            newDaily: state.daily,
            newMonthly: state.monthly,
          ));
          int start = DateTime.now().millisecondsSinceEpoch;
          await transactionService.saveTransaction(event.data);
          var copyArr = [...state.daily];
          int finish = DateTime.now().millisecondsSinceEpoch;
          if (finish - start <= 1200) {
            await Future.delayed(
                Duration(milliseconds: 1000 - (finish - start)));
          }
          emit(TransactionStateFinishLoad(
            newDaily: copyArr,
            newMonthly: state.monthly,
          ));
        } on CustomExceptionForPost catch (e) {
          if (e.codeError == 400) {
            emit(TransactionState.error(state.daily, state.monthly, e.cause));
            // print(stateStatus.message);
          } else if (e.codeError == 429) {
            // emit(TransactionStateFinishLoad(
            //   newDaily: state.daily,
            //   newMonthly: state.monthly,
            // ));
            emit(TransactionState.error(
              state.daily,
              state.monthly,
              e.cause,
            ));
            return;
          }
        } catch (err) {
          if (err.toString().contains('unauthorized')) {
            emit(TransactionState.sessionLost());
            return;
          }
          emit(TransactionState.error(
            state.daily,
            state.monthly,
            err.toString(),
          ));
        }

        // var res=
      },
      transformer: droppable(),
    );
    on<TransactionUpdateRequested>(
      (event, emit) async {
        try {
          emit(TransactionStateLoading(
            newDaily: state.daily,
            newMonthly: state.monthly,
          ));
          int start = DateTime.now().millisecondsSinceEpoch;
          await transactionService.updateTransaction(event.data);
          List<TransactionDailyModel> data = [...state.daily];
          for (int i = 0; i < data.length; i++) {
            if (data[i].id == event.data.id) {
              data[i].name = event.data.name;
              data[i].detail = event.data.detail;
              data[i].debitCredit = event.data.debitCredit;
              data[i].harga = event.data.harga;
              data[i].tanggal = event.data.tanggal;
              data[i].category = event.data.category;
              data[i].categoryId = event.data.categoryId;
              break;
            }
          }
          int finish = DateTime.now().millisecondsSinceEpoch;
          if (finish - start <= 1200) {
            await Future.delayed(
                Duration(milliseconds: 1000 - (finish - start)));
          }
          emit(TransactionStateFinishLoad(
            newDaily: data,
            newMonthly: state.monthly,
          ));
        } on CustomExceptionForPost catch (e) {
          if (e.codeError == 400) {
            emit(TransactionState.error(state.daily, state.monthly, e.cause));
            // print(stateStatus.message);
          } else if (e.codeError == 429) {
            // emit(TransactionStateFinishLoad(
            //   newDaily: state.daily,
            //   newMonthly: state.monthly,
            // ));
            emit(TransactionState.error(
              state.daily,
              state.monthly,
              e.cause,
            ));
            return;
          }
        } catch (err) {
          if (err.toString().contains('unauthorized')) {
            emit(TransactionState.sessionLost());
            return;
          }
          emit(TransactionState.error(
              state.daily, state.monthly, err.toString()));
        }

        // var res=
      },
      transformer: droppable(),
    );
    on<TransactionDeleteRequested>(
      (event, emit) async {
        // late TransactionState stateStatus;
        try {
          emit(TransactionStateLoading(
            newDaily: state.daily,
            newMonthly: state.monthly,
          ));
          int start = DateTime.now().millisecondsSinceEpoch;
          // emit(TransactionState.setLoading(true, state.daily, state.monthly));
          await transactionService.deleteTransaction(event.id);
          int finish = DateTime.now().millisecondsSinceEpoch;
          if (finish - start <= 1200) {
            await Future.delayed(
                Duration(milliseconds: 1000 - (finish - start)));
          }
          emit(TransactionStateFinishLoad(
            newDaily: state.daily.where((e) => e.id != event.id).toList(),
            newMonthly: state.monthly,
          ));
        } on CustomExceptionForPost catch (e) {
          print('error custom:' + e.codeError.toString());
          if (e.codeError == 400) {
            emit(TransactionState.error(state.daily, state.monthly, e.cause));
          } else if (e.codeError == 429) {
            // emit(TransactionStateFinishLoad(
            //   newDaily: state.daily,
            //   newMonthly: state.monthly,
            // ));
            emit(TransactionState.error(
              state.daily,
              state.monthly,
              e.cause,
            ));
            return;
          }
        } catch (err) {
          if (err.toString().contains('unauthorized')) {
            emit(TransactionState.sessionLost());
            return;
          }
          emit(TransactionState.error(
              state.daily, state.monthly, err.toString()));
        }

        // var res=
      },
      transformer: droppable(),
    );
    on<TransactionCleanMessage>((event, emit) async {
      emit(TransactionStateFinishLoad(
        newDaily: state.daily,
        newMonthly: state.monthly,
      ));
    });
    on<TransactionGetMonthlyData>(
      (event, emit) async {
        try {
          emit(TransactionStateLoading(
            newDaily: state.daily,
            newMonthly: state.monthly,
          ));
          int start = DateTime.now().millisecondsSinceEpoch;
          List<TransactionBulkModel> data =
              await transactionService.monthlyTransaction(event.year);
          int finish = DateTime.now().millisecondsSinceEpoch;
          if (finish - start <= 1200) {
            await Future.delayed(
                Duration(milliseconds: 1000 - (finish - start)));
          }
          emit(TransactionStateFinishLoad(
            newDaily: state.daily,
            newMonthly: data,
          ));
        } on CustomExceptionForPost catch (e) {
          if (e.codeError == 400) {
            emit(TransactionState.error(state.daily, state.monthly, e.cause));
            // print(stateStatus.message);
          } else if (e.codeError == 429) {
            // emit(TransactionStateFinishLoad(
            //   newDaily: state.daily,
            //   newMonthly: state.monthly,
            // ));
            emit(TransactionState.error(
              state.daily,
              state.monthly,
              e.cause,
            ));
            return;
          }
        } catch (err) {
          if (err.toString().contains('unauthorized')) {
            emit(TransactionState.sessionLost());
            return;
          }
          emit(TransactionState.error(
              state.daily, state.monthly, err.toString()));
        }

        // var res=
      },
      transformer: droppable(),
    );
  }
}
