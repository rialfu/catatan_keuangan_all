import 'package:catatan_keuangan/core/enum/auth_enum.dart';
import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:equatable/equatable.dart';

class CategoryState extends Equatable {
  final bool loading;
  final List<CategoryModel> categories;
  final AuthStatus status;
  final Object? message;
  const CategoryState._({
    this.categories = const [],
    this.loading = false,
    this.status = AuthStatus.authenticated,
    this.message,
    // this.
  });
  const CategoryState({
    this.categories = const [],
    this.loading = false,
    this.status = AuthStatus.authenticated,
    this.message,
    // this.
  });

  const CategoryState.defaultVal() : this._();
  const CategoryState.sessionLost() : this._(status: AuthStatus.guest);
  const CategoryState.setLoading(
    bool loading,
    List<CategoryModel> categories,
  ) : this._(
          categories: categories,
          loading: loading,
        );
  const CategoryState.finishLoad(
    List<CategoryModel> categories,
  ) : this._(
          categories: categories,
          loading: false,
        );
  const CategoryState.error(
    List<CategoryModel> categories,
    Object? message,
  ) : this._(
          categories: categories,
          loading: false,
          message: message,
        );

  @override
  List<Object?> get props => [loading, categories, message];
}

class CategoryStateFinishLoad extends CategoryState {
  const CategoryStateFinishLoad({
    required List<CategoryModel> newCategories,
  }) : super(categories: newCategories);
  @override
  List<Object?> get props => [super.loading, super.categories, super.status];
}
