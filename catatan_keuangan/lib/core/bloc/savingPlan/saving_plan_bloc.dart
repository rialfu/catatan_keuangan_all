import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_event.dart';
import 'package:catatan_keuangan/core/bloc/savingPlan/saving_plan_state.dart';
import 'package:catatan_keuangan/core/model/saving_plan_checkout_model.dart';
import 'package:catatan_keuangan/core/model/saving_plan_model.dart';
import 'package:catatan_keuangan/core/service/saving_plan_service.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingPlanBloc extends Bloc<SavingPlanEvent, SavingPlanState> {
  // final IAuthService authService;
  final AuthCacheManager authCacheManager;
  final SavingPlanService savingPlanService;

  SavingPlanBloc(this.authCacheManager, this.savingPlanService)
      : super(const SavingPlanState.defaultVal()) {
    on<SavingPlanStarted>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        // List<SavingPlanModel> res = await transactionService.getAllModel();
        // res.forEach((e) => print('${e.id}, ${e.canDelete}'));
        emit(SavingPlanStateFinishLoad(data: []));
      } catch (err) {
        print(err);
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
    on<SavingPlanRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        print('request sp');
        List<SavingPlanModel> res = await savingPlanService.getAllSavingPlan();
        emit(SavingPlanStateFinishLoad(data: res));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }

      // var res=
    });
    on<SavingPlanSaveRequested>((event, emit) async {
      // late TransactionState stateStatus;
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        var data = [...(state.savingPlans)];
        // print(event.data);
        String? id = await savingPlanService.saveSavingPlan(event.data);
        if (id != null) {
          Map<String, dynamic> cache = event.data.toJsonSave();
          cache['id'] = id;
          data.add(SavingPlanModel.fromJson(cache));
        }
        data.sort((a, b) => b.targetDate.compareTo(a.targetDate));
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
    on<SavingPlanUpdateRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        var data = [...(state.savingPlans)];
        await savingPlanService.updateSavingPlan(event.data);
        data.map((e) {
          if (e.id == event.data.id) {
            return event.data;
          }
          return e;
        });
        data.sort((a, b) => b.targetDate.compareTo(a.targetDate));
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
        }
      } catch (err) {
        print(err);
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
    on<SavingPlanDeleteRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        await savingPlanService.deleteSavingPlan(event.id);
        var data = [...(state.savingPlans)];
        data.removeWhere((e) => e.id == event.id);
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
        }
      } catch (err) {
        print(err);
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
    on<SavingPlanCleanMessage>((event, emit) async {
      emit(SavingPlanState.finishLoad(state.savingPlans));
    });
    on<SavingPlanCheckoutRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        List<SavingPlanCheckoutModel> data =
            await savingPlanService.getListCheckout(event.id);
        List<SavingPlanModel> newData = state.savingPlans.map((e) {
          if (e.id != event.id) return e;
          return SavingPlanModel(
            id: e.id,
            name: e.name,
            targetDate: e.targetDate,
            targetMoney: e.targetMoney,
            dateReminder: e.dateReminder,
            typeReminder: e.typeReminder,
            checkout: data,
          );
        }).toList();

        emit(SavingPlanStateFinishLoad(data: newData));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
        }
      } catch (err) {
        print(err);
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
  }
}
