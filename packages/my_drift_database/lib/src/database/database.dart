// don't import moor_web.dart or moor_flutter/moor_flutter.dart in shared code
import 'package:drift/drift.dart';

export 'construct_db/shared.dart';

part 'database.g.dart';
/*-----------------------------------------------------------------------------*/

@DataClassName('TodoEntry')
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get content => text()();

  DateTimeColumn get targetDate => dateTime().nullable()();

  IntColumn get category => integer()
      .nullable()
      .customConstraint('NULLABLE REFERENCES categories(id)')();
}

/*-----------------------------------------------------------------------------*/

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get description => text().named('desc').nullable()();
}

/*-----------------------------------------------------------------------------*/

class CategoryWithCount {
  CategoryWithCount(this.category, this.count);

  // can be null, in which case we count how many entries don't have a category
  final Category? category;
  final int count; // amount of entries in this category
}

/*-----------------------------------------------------------------------------*/

class EntryWithCategory {
  EntryWithCategory(this.entry, this.category);

  final TodoEntry entry;
  final Category? category;
}

/*-----------------------------------------------------------------------------*/

@DriftDatabase(
  tables: [Todos, Categories],
  queries: {
    '_resetCategory': 'UPDATE todos SET category = NULL WHERE category = ?',
  },
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(todos, todos.targetDate);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // create default categories and entries
          final workId = await into(categories)
              .insert(const CategoriesCompanion(description: Value('Work')));

          await into(todos).insert(TodosCompanion(
            content: const Value('A first todo entry'),
            targetDate: Value(DateTime.now()),
          ));

          await into(todos).insert(
            TodosCompanion(
              content: const Value('Rework persistence code'),
              category: Value(workId),
              targetDate: Value(
                DateTime.now().add(const Duration(days: 4)),
              ),
            ),
          );
        }
      },
    );
  }

  Stream<List<CategoryWithCount>> categoriesWithCount() {
    // select all categories and load how many associated entries there are for
    // each category
    return customSelect(
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

  Future<int> createTodo(TodosCompanion entry) async {
    return into(todos).insert(entry);
  }

  Future updateTodo(TodoEntry entry) async {
    return update(todos).replace(entry);
  }

  Future deleteTodo(TodoEntry entry) {
    return delete(todos).delete(entry);
  }

  Future<int> createCategory(String description) {
    return into(categories).insert(
      CategoriesCompanion(description: Value(description)),
    );
  }

  Future deleteCategory(Category category) {
    return transaction(() async {
      await _resetCategory(category.id);
      await delete(categories).delete(category);
    });
  }
}
/*-----------------------------------------------------------------------------*/