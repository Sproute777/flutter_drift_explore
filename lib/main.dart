import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_drift_database/my_drift_database.dart';

import 'ui/cubit/todo_bloc.dart';
import 'ui/home/screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Database>(
      create: (context) => constructDb(),
      child: RepositoryProvider<TodosDao>(
        create: (context) {
          final db = RepositoryProvider.of<Database>(context);
          return TodosDao(db)..init();
        },
        child: BlocProvider(
          create: (context) =>
              TodoCubit(RepositoryProvider.of<TodosDao>(context)),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.orange,
              typography: Typography.material2018(
                englishLike: Typography.englishLike2018,
                dense: Typography.dense2018,
                tall: Typography.tall2018,
              ),
            ),
            home: HomeScreen(),
          ),
        ),
      ),
    );
  }
}
