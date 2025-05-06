import 'package:catatan_keuangan/core/model/category_model.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryStarted extends CategoryEvent {}

class CategoryRequested extends CategoryEvent {
  // final String date;

  const CategoryRequested();

  // @override
  // List<Object?> get props => [date];
}

class CategorySaveRequested extends CategoryEvent {
  final CategoryModel data;
  const CategorySaveRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class CategoryUpdateRequested extends CategoryEvent {
  final CategoryModel data;
  const CategoryUpdateRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class CategoryDeleteRequested extends CategoryEvent {
  final int id;
  const CategoryDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class CategoryCleanMessage extends CategoryEvent {
  // final CategoryDailyModel data;
  const CategoryCleanMessage();
  // @override
  // List<Object?> get props => [data];
}
