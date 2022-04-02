import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_drift_database/my_drift_database.dart';

import 'ui/cubit/todo_bloc.dart';
import 'ui/home/screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final Database database = constructDb();
  final TodosDao todosDao = TodosDao(database);
  runApp(MyApp(database: database, dao: todosDao));
}

class MyApp extends StatelessWidget {
  final Database database;
  final TodosDao dao;
  const MyApp({required this.database, required this.dao}) : super();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Database>.value(
      value: database,
      child: RepositoryProvider<TodosDao>.value(
        value: dao..init(),
        child: BlocProvider(
          create: (context) =>
              TodoCubit(RepositoryProvider.of<TodosDao>(context)),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              typography: Typography.material2014(
                englishLike: Typography.englishLike2014,
                dense: Typography.dense2014,
                tall: Typography.tall2014,
              ),
            ),
            home: HomeScreen(),
          ),
        ),
      ),
    );
  }
}
