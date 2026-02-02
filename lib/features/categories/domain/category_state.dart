import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_app/shared/models/category.dart';

part 'category_state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default(false) bool isLoading,
    @Default([]) List<Category> categories,
    String? error,
  }) = _CategoryState;

  factory CategoryState.initial() => const CategoryState(
        isLoading: false,
        categories: [],
        error: null,
      );

  factory CategoryState.loading() => const CategoryState(
        isLoading: true,
        categories: [],
        error: null,
      );

  factory CategoryState.loaded(List<Category> categories) => CategoryState(
        isLoading: false,
        categories: categories,
        error: null,
      );

  factory CategoryState.error(String error) => CategoryState(
        isLoading: false,
        categories: [],
        error: error,
      );
}