part of 'todo_bloc.dart';

enum TodoStatus { waiting, success, noData }

class TodoState extends Equatable {
  final List<EntryWithCategory>? entries;
  final List<CategoryWithActiveInfo> categories;
  final TodoStatus status;

  const TodoState(
      {this.entries = const <EntryWithCategory>[],
      this.categories = const <CategoryWithActiveInfo>[],
      this.status = TodoStatus.waiting});

  TodoState newEntries({
    List<EntryWithCategory>? entries,
  }) {
    if (entries != null)
      return TodoState(
          entries: entries,
          status: TodoStatus.success,
          categories: this.categories);
    else {
      return TodoState(
          entries: null,
          status: TodoStatus.noData,
          categories: this.categories);
    }
  }

  TodoState newCategories({
    required List<CategoryWithActiveInfo> c,
  }) {
    return TodoState(
        entries: this.entries, status: TodoStatus.success, categories: c);
  }

  @override
  List<Object?> get props => [entries, status, categories];
}
