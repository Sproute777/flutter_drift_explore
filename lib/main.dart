import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/blocs/todo.dart';
import 'plugins/desktop/desktop.dart'; //
import 'src/database/database.dart';
import 'ui/home/screen.dart';

void main() {
  setTargetPlatformForDesktop();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Database>(
      create: (context) => constructDb(),
      child: RepositoryProvider<TodoApp>(
        create: (context) {
          final db = RepositoryProvider.of<Database>(context);
          return TodoApp(db);
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Drift Demo',
          theme: ThemeData(
            primarySwatch: Colors.orange,
            // use the good-looking updated material text style
            typography: Typography.material2018(
              englishLike: Typography.englishLike2018,
              dense: Typography.dense2018,
              tall: Typography.tall2018,
            ),
          ),
          home: HomeScreen(),
        ),
      ),
    );
  }
}
