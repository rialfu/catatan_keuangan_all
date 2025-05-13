import 'package:bloc_concurrency/bloc_concurrency.dart';
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
        emit(SavingPlanStateFinishLoad(data: []));
      } catch (err) {
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    });
    on<SavingPlanRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        List<SavingPlanModel> res = await savingPlanService.getAllSavingPlan();
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: res));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }

      // var res=
    }, transformer: droppable());
    on<SavingPlanSaveRequested>((event, emit) async {
      // late TransactionState stateStatus;
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        var data = [...(state.savingPlans)];
        String? id = await savingPlanService.saveSavingPlan(event.data);
        if (id != null) {
          Map<String, dynamic> cache = event.data.toJsonSave();
          cache['id'] = id;
          data.add(SavingPlanModel.fromJson(cache));
        }
        data.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanUpdateRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        var data = [...(state.savingPlans)];
        await savingPlanService.updateSavingPlan(event.data);
        data = data.map((e) {
          if (e.id == event.forUpdate.id) {
            return event.forUpdate;
          }
          return e;
        }).toList();
        data.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429 || e.codeError == 422) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanNotificationRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        var data = [...(state.savingPlans)];
        await savingPlanService.updateSavingPlan(event.data);
        data = data.map((e) {
          if (e.id == event.data['id']) {
            return e.update(
                newNotification: event.data['notification'] as bool);
          }
          return e;
        }).toList();
        data.sort((a, b) => a.targetDate.compareTo(b.targetDate));
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanDeleteRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        await savingPlanService.deleteSavingPlan(event.id);
        var data = [...(state.savingPlans)];
        data.removeWhere((e) => e.id == event.id);
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanCleanMessage>((event, emit) async {
      emit(SavingPlanState.finishLoad(state.savingPlans));
    });
    on<SavingPlanCheckoutRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        List<SavingPlanCheckoutModel> data =
            await savingPlanService.getListCheckout(event.id);
        List<SavingPlanModel> newData = state.savingPlans.map((e) {
          if (e.id != event.id) return e;
          return e.update(newCheckout: data);
        }).toList();
        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: newData));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanCheckoutSavingRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        int? id = await savingPlanService.savingStore(
          event.data,
          event.idSavingPlan,
        );
        var data = [...state.savingPlans];
        if (id != null) {
          data = data.map((e) {
            if (e.id == event.idSavingPlan) {
              var newCheckout = [...e.checkout];
              newCheckout.add(SavingPlanCheckoutModel(
                id: id,
                money: event.data.money,
                dateCheckout: event.data.dateCheckout,
              ));

              return e.update(newCheckout: newCheckout);
            }
            return e;
          }).toList();
        }

        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
    on<SavingPlanCheckoutDeleteRequested>((event, emit) async {
      emit(SavingPlanStateLoad(data: state.savingPlans));
      try {
        int start = DateTime.now().millisecondsSinceEpoch;

        await savingPlanService.deleteStore(
          event.id,
        );
        var data = state.savingPlans.map((e) {
          if (e.id == event.idSavingPlan) {
            var checkout = [...e.checkout];
            checkout = e.checkout.where((c) => c.id != event.id).toList();
            return e.update(newCheckout: checkout);
          }
          return e;
        }).toList();

        int finish = DateTime.now().millisecondsSinceEpoch;
        if (finish - start <= 1200) {
          await Future.delayed(Duration(milliseconds: 1000 - (finish - start)));
        }
        emit(SavingPlanStateFinishLoad(data: data));
      } on CustomExceptionForPost catch (e) {
        if (e.codeError == 400 || e.codeError == 429) {
          emit(SavingPlanState.error(state.savingPlans, e.cause));
          return;
        }
        emit(SavingPlanStateFinishLoad(data: state.savingPlans));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(SavingPlanState.sessionLost());
          return;
        }
        emit(SavingPlanState.error(state.savingPlans, err.toString()));
      }
    }, transformer: droppable());
  }
}
