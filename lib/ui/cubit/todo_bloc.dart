import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_drift_database/my_drift_database.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepo _database;
  StreamSubscription? _subscriptionTodo;
  StreamSubscription? _subscriptionCategory;

  TodoCubit(TodoRepo database)
      : _database = database,
        super(TodoState()) {
    _subscriptionTodo = _database.homeScreenEntries?.listen((event) {
      _fresh(event);
    });
    _subscriptionCategory = _database.categories.listen((event) {
      _newCatefories(event);
    });
  }

  void _fresh(List<EntryWithCategory> entries) =>
      emit(state.newEntries(entries: entries));

  void _newCatefories(List<CategoryWithActiveInfo> category) =>
      emit(state.newCategories(c: category));

  void createTodo(String text) => _database.createEntry(text);
  void deleteEntry(TodoEntry entry) => _database.deleteEntry(entry);
  void updateEntry(TodoEntry entry) => _database.updateEntry(entry);

  void addCategory(String text) => _database.addCategory(text);
  void deleteCategory(Category category) => _database.deleteCategory(category);

  Future<void> close() {
    _subscriptionTodo?.cancel();
    _subscriptionCategory?.cancel();
    return super.close();
  }
}
