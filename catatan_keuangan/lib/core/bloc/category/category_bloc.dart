import 'package:catatan_keuangan/core/bloc/category/category_event.dart';
import 'package:catatan_keuangan/core/bloc/category/category_state.dart';
import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:catatan_keuangan/core/service/transaction_service.dart';
import 'package:catatan_keuangan/customClass/custom_exception.dart';
import 'package:catatan_keuangan/init/cache/auth_cache_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  // final IAuthService authService;
  final AuthCacheManager authCacheManager;
  final TransactionService transactionService;

  CategoryBloc(this.authCacheManager, this.transactionService)
      : super(const CategoryState.defaultVal()) {
    on<CategoryStarted>((event, emit) async {
      emit(CategoryState.setLoading(true, state.categories));
      try {
        List<CategoryModel> res = await transactionService.getAllCategory();

        emit(CategoryStateFinishLoad(newCategories: res));
      } catch (err) {
        print(err);
        emit(CategoryState.error(state.categories, err.toString()));
      }
    });
    on<CategoryRequested>((event, emit) async {
      emit(CategoryState.setLoading(true, state.categories));
      try {
        List<CategoryModel> res = await transactionService.getAllCategory();
        emit(CategoryStateFinishLoad(newCategories: res));
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(CategoryState.sessionLost());
          return;
        }
        print(err);
        emit(CategoryState.error(state.categories, err.toString()));
      }

      // var res=
    });
    on<CategorySaveRequested>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(CategoryState.setLoading(
          true,
          state.categories,
        ));
        // print(event.data);
        int? id = await transactionService.saveCategory(event.data);
        print('data:$id');
        var data = [...state.categories];
        if (id != null) {
          data.add(CategoryModel(id, event.data.name, canDelete: true));
        }
        emit(CategoryStateFinishLoad(
          newCategories: data,
        ));
        // print(res);
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(CategoryState.error(state.categories, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(CategoryState.sessionLost());
          return;
        }
        emit(CategoryState.error(state.categories, err.toString()));
      }
    });
    on<CategoryUpdateRequested>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(CategoryState.setLoading(
          true,
          state.categories,
        ));
        await transactionService.updateCategory(event.data);
        emit(CategoryStateFinishLoad(
          newCategories: state.categories,
        ));
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          emit(CategoryState.error(state.categories, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        print(err);
        if (err.toString().contains('unauthorized')) {
          emit(CategoryState.sessionLost());
          return;
        }
        emit(CategoryState.error(state.categories, err.toString()));
      }

      // var res=
    });
    on<CategoryDeleteRequested>((event, emit) async {
      // late TransactionState stateStatus;
      try {
        emit(CategoryState.setLoading(
          true,
          state.categories,
        ));
        await transactionService.deleteCategory(event.id);

        emit(CategoryState.finishLoad(
          state.categories.where((e) => e.id != event.id).toList(),
        ));
        // print(res);
      } on CustomExceptionForPost catch (e) {
        print('error custom:' + e.codeError.toString());
        if (e.codeError == 400) {
          print(e.cause);
          emit(CategoryState.error(state.categories, e.cause));
          // print(stateStatus.message);
        }
      } catch (err) {
        if (err.toString().contains('unauthorized')) {
          emit(CategoryState.sessionLost());
          return;
        }
        emit(CategoryState.error(state.categories, err.toString()));
      }

      //   // var res=
    });
    on<CategoryCleanMessage>((event, emit) async {
      emit(CategoryState.finishLoad(state.categories));
    });
  }
}
