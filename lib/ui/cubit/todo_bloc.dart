import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../my_drift_database/my_drift_database.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodosDao _repository;
  StreamSubscription? _subscriptionTodo;
  StreamSubscription? _subscriptionCategory;

  TodoCubit(TodosDao repository)
      : _repository = repository,
        super(TodoState()) {
    _subscriptionTodo = _repository.homeScreenEntries?.listen((event) {
      _fresh(event);
    });
    _subscriptionCategory = _repository.ctg.listen((event) {
      _newCategories(event);
    });
  }

  void _fresh(List<EntryWithCategory> entries) =>
      emit(state.newEntries(entries: entries));

  void _newCategories(List<CategoryWithActiveInfo> category) =>
      emit(state.newCategories(c: category));

  void createTodo(String text) => _repository.createTodo(text);
  void deleteEntry(TodoEntry entry) => _repository.deleteTodo(entry);
  void updateEntry(TodoEntry entry) => _repository.updateTodo(entry);

  void addCategory(String text) => _repository.createCategory(text);
  void showCategory(Category? c) => _repository.showCategory(c);
  void deleteCategory(Category category) =>
      _repository.deleteCategory(category);

  Future<void> close() {
    _subscriptionTodo?.cancel();
    _subscriptionCategory?.cancel();
    _repository.close();
    return super.close();
  }
}
