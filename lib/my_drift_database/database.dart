// don't import moor_web.dart or moor_flutter/moor_flutter.dart in shared code
import 'package:drift/drift.dart';

import 'category_table.dart';
import 'todo_table.dart';
import 'todos_dao.dart';

export 'construct_db/shared.dart';

part 'database.g.dart';
/*-----------------------------------------------------------------------------*/

// @DataClassName('TodoEntry')
// class Todos extends Table {
//   IntColumn get id => integer().autoIncrement()();

//   TextColumn get content => text()();

//   DateTimeColumn get targetDate => dateTime().nullable()();

//   IntColumn get category => integer()
//       .nullable()
//       .customConstraint('NULLABLE REFERENCES categories(id)')();
// }

// /*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/

@DriftDatabase(
  tables: [Todos, Categories],
  daos: [TodosDao],
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

  // Future<int> createTodo(TodosCompanion entry) async {
  //   return into(todos).insert(entry);
  // }

  // Future updateTodo(TodoEntry entry) async {
  //   return update(todos).replace(entry);
  // }

  // Future deleteTodo(TodoEntry entry) {
  //   return delete(todos).delete(entry);
  // }

}
/*-----------------------------------------------------------------------------*/