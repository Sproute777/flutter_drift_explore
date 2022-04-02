import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../my_drift_database/database.dart';
import '../../my_drift_database/todos_dao.dart';

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
      _newCatefories(event);
    });
  }

  void _fresh(List<EntryWithCategory> entries) =>
      emit(state.newEntries(entries: entries));

  void _newCatefories(List<CategoryWithActiveInfo> category) =>
      emit(state.newCategories(c: category));

  void createTodo(String text) => _repository.createTodo(text);
  void deleteEntry(TodoEntry entry) => _repository.deleteTodo(entry);
  void updateEntry(TodoEntry entry) => _repository.updateTodo(entry);

  void addCategory(String text) => _repository.createCategory(text);
  // void deleteCategory(Category category) => _repository.deleteCategory(category);

  Future<void> close() {
    _subscriptionTodo?.cancel();
    _subscriptionCategory?.cancel();
    return super.close();
  }
}
