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
    on<TransactionDailyRequested>((event, emit) async {
      try {
        emit(TransactionState.setLoading(true, state.daily, state.monthly));
        var res = await transactionService.getTransaction(dateData: event.date);

        emit(TransactionState.finishLoad(res, state.monthly));
        // print(res);
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(TransactionState.sessionLost());
          return;
        }
        emit(
            TransactionState.error(state.daily, state.monthly, err.toString()));
        print(err.toString().contains('unauthorized'));
        // err.toString()
        print(err);
      }

      // var res=
    });
    on<TransactionSaveRequested>((event, emit) async {
      try {
        emit(TransactionState.setLoading(true, state.daily, state.monthly));
        await transactionService.saveTransaction(event.data);
        var copyArr = [...state.daily];
        emit(TransactionStateFinishLoad(
          newDaily: copyArr,
          newMonthly: state.monthly,
        ));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400) {
          emit(TransactionState.error(state.daily, state.monthly, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(TransactionState.sessionLost());
          return;
        }
        emit(
            TransactionState.error(state.daily, state.monthly, err.toString()));
        print(err.toString().contains('unauthorized'));
        // err.toString()
        print(err);
      }

      // var res=
    });
    on<TransactionUpdateRequested>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(TransactionState.setLoading(true, state.daily, state.monthly));
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
            print(data[i].toJson());
            break;
          }
        }
        emit(TransactionStateFinishLoad(
          newDaily: data,
          newMonthly: state.monthly,
        ));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(TransactionState.error(state.daily, state.monthly, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(TransactionState.sessionLost());
          return;
        }
        emit(
            TransactionState.error(state.daily, state.monthly, err.toString()));
      }

      // var res=
    });
    on<TransactionDeleteRequested>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(TransactionState.setLoading(true, state.daily, state.monthly));
        await transactionService.deleteTransaction(event.id);

        emit(TransactionState.finishLoad(
            state.daily.where((e) => e.id != event.id.toString()).toList(),
            state.monthly));
        // print(res);
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(TransactionState.error(state.daily, state.monthly, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(TransactionState.sessionLost());
          return;
        }
        emit(
            TransactionState.error(state.daily, state.monthly, err.toString()));
      }

      // var res=
    });
    on<TransactionCleanMessage>((event, emit) async {
      emit(TransactionState.finishLoad(state.daily, state.monthly));
    });
    on<TransactionGetMonthlyData>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(TransactionState.setLoading(true, state.daily, state.monthly));
        List<TransactionBulkModel> data = await transactionService
            .monthlyTransaction(event.year) as List<TransactionBulkModel>;

        emit(TransactionState.finishLoad(
          state.daily,
          data,
        ));
        // print(res);
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(TransactionState.error(state.daily, state.monthly, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(TransactionState.sessionLost());
          return;
        }
        emit(
            TransactionState.error(state.daily, state.monthly, err.toString()));
      }

      // var res=
    });
  }
}
