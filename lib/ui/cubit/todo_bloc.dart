import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../my_drift_database/database.dart';
import '../../my_drift_database/todos_dao.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodosDao _database;
  StreamSubscription? _subscriptionTodo;
  StreamSubscription? _subscriptionCategory;

  TodoCubit(TodosDao database)
      : _database = database,
        super(TodoState()) {
    _subscriptionTodo = _database.homeScreenEntries?.listen((event) {
      _fresh(event);
    });
    _subscriptionCategory = _database.ctg.listen((event) {
      _newCatefories(event);
    });
  }

  void _fresh(List<EntryWithCategory> entries) =>
      emit(state.newEntries(entries: entries));

  void _newCatefories(List<CategoryWithActiveInfo> category) =>
      emit(state.newCategories(c: category));

  void createTodo(String text) => _database.createTodo(text);
  void deleteEntry(TodoEntry entry) => _database.deleteTodo(entry);
  void updateEntry(TodoEntry entry) => _database.updateTodo(entry);

  void addCategory(String text) => _database.createCategory(text);
  // void deleteCategory(Category category) => _database.deleteCategory(category);

  Future<void> close() {
    _subscriptionTodo?.cancel();
    _subscriptionCategory?.cancel();
    return super.close();
  }
}
