import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../my_drift_database.dart';

part 'todos_dao.g.dart';

class CategoryWithCount {
  CategoryWithCount(this.category, this.count);

  final Category? category;
  final int count; // amount of entries in this category
}

/*-----------------------------------------------------------------------------*/

class EntryWithCategory {
  EntryWithCategory(this.entry, this.category);

  final TodoEntry entry;
  final Category? category;
}

class CategoryWithActiveInfo {
  CategoryWithActiveInfo(this.categoryWithCount, this.isActive);

  CategoryWithCount categoryWithCount;
  bool isActive;
}

@DriftAccessor(tables: [Todos, Categories])
class TodosDao extends DatabaseAccessor<Database> with _$TodosDaoMixin {
  final Database database;
  TodosDao(this.database) : super(database);

  Future<int> _createTodo(TodosCompanion entry) async {
    return into(todos).insert(entry);
  }

  void createTodo(String content) async {
    await _createTodo(TodosCompanion(
      content: Value(content),
      category: Value(_activeCategory.value?.id),
    ));
  }

  void updateTodo(TodoEntry entry) {
    update(todos).replace(entry);
  }

  Future<int> deleteTodo(TodoEntry entry) async {
    return await delete(todos).delete(entry);
  }

  final BehaviorSubject<Category?> _activeCategory =
      BehaviorSubject.seeded(null);

  final BehaviorSubject<List<CategoryWithActiveInfo>> _allCategories =
      BehaviorSubject();

  Stream<List<EntryWithCategory>>? _currentEntries;

  Stream<List<EntryWithCategory>>? get homeScreenEntries => _currentEntries;

  Stream<List<CategoryWithActiveInfo>> get ctg => _allCategories;

  void init() {
    _currentEntries = _activeCategory.switchMap(watchEntriesInCategory);

    // also watch all categories so that they can be displayed in the navigation
    // drawer.
    Rx.combineLatest2<List<CategoryWithCount>, Category?,
        List<CategoryWithActiveInfo>>(
      categoriesWithCount(),
      _activeCategory,
      (allCategories, selected) {
        return allCategories.map((category) {
          final isActive = selected?.id == category.category?.id;

          return CategoryWithActiveInfo(category, isActive);
        }).toList();
      },
    ).listen(_allCategories.add);
  }

  Stream<List<CategoryWithCount>> categoriesWithCount() {
    // select all categories and load how many associated entries there are for
    // each category
    return database.customSelect(
      'SELECT c.id, c.desc, '
      '(SELECT COUNT(*) FROM todos WHERE category = c.id) AS amount '
      'FROM categories c '
      'UNION ALL SELECT null, null, '
      '(SELECT COUNT(*) FROM todos WHERE category IS NULL)',
      readsFrom: {todos, categories},
    ).map((row) {
      // when we have the result set, map each row to the data class
      final hasId = row.data['id'] != null;

      return CategoryWithCount(
        hasId ? Category.fromData(row.data) : null,
        row.read<int>('amount'),
      );
    }).watch();
  }

  Stream<List<EntryWithCategory>> watchEntriesInCategory(Category? category) {
    if (category != null) {
      final query = select(todos).join(
        [leftOuterJoin(categories, categories.id.equalsExp(todos.category))],
      )..where(categories.id.equals(category.id));

      return query.watch().map((rows) {
        // read both the entry and the associated category for each row
        return rows.map((row) {
          return EntryWithCategory(
            row.readTable(todos),
            row.readTable(categories),
          );
        }).toList();
      });
    }

    final query = select(todos)..where((t) => todos.category.isNull());

    return query.watch().map((rows) {
      // read both the entry and the associated category for each row
      return rows.map((row) {
        return EntryWithCategory(row, null);
      }).toList();
    });
  }

  Future<int> createCategory(String description) {
    return into(categories).insert(
      CategoriesCompanion(description: Value(description)),
    );
  }

  Future deleteCategory(Category category) {
    return delete(categories).delete(category);
  }
}
